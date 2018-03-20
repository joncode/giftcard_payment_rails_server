class Web::V4::AssociationsController < MetalCorsController
    before_action :debug_output
    before_action :authentication_token_required, except: [:list_roles]
    before_action :verify_owner,                  except: [:list_roles, :list_user, :associate, :authorize, :deauthorize]
    before_action :clean_roles,                   only:   [:associate]
    before_action :authenticate_admin,            only:   [:list_entity, :new_code, :delete_code, :list_entity_pending, :list_entity_users]
    before_action :verify_sufficient_permissions, only:   [:authorize, :deauthorize]



    ##@ PATCH /:owner_type/:owner_id/generate_codes
    def debug_generate_codes
        codes = []
        ::UserAccessRole.all.each do |role|
            next  if ::UserAccessCode.where(active: true).where(owner: @owner, role_id: role.id).count > 0

            code = ::UserAccessCode.new
            code.role = role
            code.code = generate_code
            code.owner = @owner
            code.approval_required = false
            code.save

            codes << as_json_with_role_data(code)
        end

        # Return all codes for the merchant
        codes = ::UserAccessCode.where(active: true).where(owner: @owner).map do |code|
            # with role data
            as_json_with_role_data(code)
        end
        success({ codes: codes.as_json })
        respond
    end


    # GET /roles
    def list_roles
        # Despite the name, ARel#as_json returns a Ruby hash
        success({ roles: ::UserAccessRole.all.as_json })  # And this will call #to_json on it.
        respond
    end


    # GET /
    def list_user
        # Returns:  association_id, merchant, access type, access role, approval status

        # Fetch access grants
        access_grants = ::UserAccess.where(active: true).where(user_id: @current_user.id)
        if access_grants.empty?
            success({ associations: [] })
            return respond
        end

        # Parse grants and construct response
        associations = []
        access_grants.each do |grant|

            # Catch malformed access grants
            if grant.owner.nil?
                puts "[api v4 Associations::list_user] Warning: UserAccess[#{grant.id}] has no owner."
                # and skip them
                next
            end

            owner = nil
            if grant.owner_type.capitalize == "Merchant"
                owner = {
                    id:        grant.owner.id,
                    name:      grant.owner.name,
                    address:   grant.owner.address,
                    address_2: grant.owner.address_2,
                    city_name: grant.owner.city_name,
                    state:     grant.owner.state,
                    zip:       grant.owner.zip,
                    photo:     grant.owner.photo,
                    photo_l:   grant.owner.photo_l,
                    r_sys:     grant.owner.r_sys,
                    hex_id:    grant.owner.hex_id,
                    active:    grant.owner.active,
                }
            end

            if grant.owner_type.capitalize == "Affiliate"
                owner = {
                    id:        grant.owner.id,
                    name:      grant.owner.name,
                    address:   grant.owner.address,
                    city_name: grant.owner.city_name,
                    state:     grant.owner.state,
                    zip:       grant.owner.zip,
                    phone:     grant.owner.phone,
                    url_name:  grant.owner.url_name,
                }
            end


            associations << {
                id:         grant.id,
                owner:      owner,
                owner_type: grant.owner_type.capitalize,
                role:       grant.role.role,
                role_id:    grant.role.id,
                role_label: grant.role.label,
                approved:   grant.approved_at.present?,
            }
        end


        success({ associations: associations.as_json })
        respond
    end


    # POST /
    def associate
        #   Input:  code
        # Actions:  Push notification and or email to admins of pending access grant  ##TODO
        # Returns:  association object

        # Verify presence
        if params[:code].blank?
            fail_web({ msg: "Missing code" })
            return respond
        end

        # Fetch code and verify presence
        code = ::UserAccessCode.where(active: true).find_by_code(params[:code])  rescue nil
        if code.nil?
            fail_web({ msg: "No matching code found" })
            return respond
        end

        # Disallow if user access level > code access level
        # (This allows switching between roles of the same level)
        user_grant = ::UserAccess.where(active: true).where(user_id: @current_user.id, owner: code.owner).first
        if user_grant.present?
            if access_level(user_grant.role.role) < access_level(code.role.role)
                fail_web({ msg: "Denied: User access level exceeds code access level" })
                return respond
            end
        end


        # Create the grant
        grant = ::UserAccess.new
        grant.user_id      = @current_user.id
        grant.owner        = code.owner
        grant.role_id      = code.role_id
        grant.approved_at  = DateTime.now  unless code.approval_required
        grant.save

        # Deactivate all other grants as well if this code does not require moderation
        unless code.approval_required
            ::UserAccess.where(active: true)  \
                .where(user_id: @current_user.id, owner: code.owner)  \
                .where.not(id: grant.id)  \
                .update_all(active: false)
        end

        # return the new grant (with added Role data)
        success({ association: as_json_with_role_data(grant) })
        return respond

    end


    # DELETE /
    def disassociate
        # Input:    owner_id, owner_type, association_id
        # Returns:  updated association object

        association_id = params[:association_id] || nil

        if association_id.nil?
            fail_web({ msg: "Missing association_id" })
            return respond
        end

        # Fetch UserAccess grant
        grant = ::UserAccess.where(active: true, owner: @owner).where(id: association_id).first
        if grant.nil?
            fail_web({ association: nil, msg: "No association found" })
            return respond
        end

        # Deactivate UserAccess grant and return it
        grant.active = false
        grant.save

        # Pass the Role data to the client
        success({ association: as_json_with_role_data(grant) })
        respond
    end



    # GET /:owner_type/:owner_id
    def list_entity
        # Requires:  Admin Access
        #    Input:  owner_type, owner_id
        #  Returns:  [{id, code, role}, ...]

        codes = ::UserAccessCode.where(active: true).where(owner: @owner).collect do |code|
            as_json_with_role_data(code)
        end

        success({ codes: codes.as_json })
        respond
    end


    # PATCH /:owner_type/:owner_id
    def new_code
        # Requires:  Admin Access
        #    Input:  owner_type, owner_id, (role | role_id), moderate=false
        #  Returns:  {id, code, role, active}

        role_id   = params[:role_id] || nil
        role_code = params[:role]    || nil

        if role_id.nil? && role_code.nil?
            fail_web({ msg: "Missing role_id, role; both cannot be blank" })
            return respond
        end

        # Find the UserAccessRole; `role_id` takes precedence.
        role = nil
        role = UserAccessRole.find_by_role(role_code) rescue nil  if role_code.present?
        role = UserAccessRole.find(role_id)           rescue nil  if role_id.present?

        if role.nil?
            fail_web({ msg: "Role not found" })
            return respond
        end

        # Disable all existing access codes for this role at this merchant
        ::UserAccessCode.where(active: true).where(owner: @owner, role_id: role.id).each do |code|
            code.active = false
            code.save
        end

        # Create the new access code
        code = ::UserAccessCode.new
        code.role        = role
        code.code        = generate_code
        code.owner       = @owner
        code.created_by  = @current_user.id
        code.approval_required = (["t", "true", "1", true].include? params[:moderate])
        code.save

        success({ code: as_json_with_role_data(code) })
        respond
    end


    # DELETE /:owner_type/:owner_id/:code_id
    def delete_code
        # Requires:  Admin Access
        #    Input:  owner_type, owner_id, code_id
        #  Returns:  {id, code role, active}

        if params[:code_id].empty?
            fail_web({ msg: "Missing code_id" })
            return respond
        end


        code = ::UserAccessCode.where(active: true).where(owner: @owner, id: params[:code_id]).first
        if code.nil?
            fail_web({ msg: "Code not found" })
            return respond
        end

        code.active = false
        code.save

        success({ code: as_json_with_role_data(code) })
        respond
    end


    # GET /:owner_type/:owner_id/pending
    def list_entity_pending
        # Requires:  Admin Access
        #    Input:  owner_type, owner_id
        #  Returns:  [{id, user, role_id, type}, ...]
        #   Caveat:  pending merchant grants also include pending affiliate grants for that merchant.

        # Fetch pending grants
        types = []
        types.push ::UserAccess.where(active: true, approved_at: nil).where(owner: @owner).to_a
        if @owner_type == "Merchant"
            affiliate_id = @owner.affiliate_id
            types.push ::UserAccess.where(active: true, approved_at: nil).where(owner_id: affiliate_id, owner_type: "Affiliate").to_a
        end
        types.reject!{ |array| array.empty? }

        # Process pending grants
        pending = []
        types.each do |grants|
            grants.each do |grant|
                user = grant.user

                pending << {
                    id:  grant.id,
                    user: {
                        id:    user.id,
                        name:  user.name,
                        email: user.email,
                        city:  user.city,
                        state: user.state,
                        zip:   user.zip,
                        sex:   user.sex,
                    },
                    role:       grant.role.role,  # Sadness.
                    role_id:    grant.role_id,
                    role_label: grant.role.label,
                    owner_type: grant.owner_type,
                }
            end
        end

        success({ pending: pending.as_json })
        respond
    end


    # GET /:owner_type/:owner_id/users
    def list_entity_users
        # Requires:  Admin Access
        #    Input:  owner_type, owner_id
        #  Returns:  [{id, user, role_id, type}, ...]
        #   Caveat:  merchant users also include affiliate users for that merchant.

        # Fetch all grants
        types = []
        types.push ::UserAccess.where(active: true).where(owner: @owner).to_a
        if @owner_type == "Merchant"
            affiliate_id = @owner.affiliate_id
            types.push ::UserAccess.where(active: true).where(owner_id: affiliate_id, owner_type: "Affiliate").to_a
        end
        types.reject!{ |array| array.empty? }


        # Process grants
        users = []
        types.each do |grants|
            grants.each do |grant|
                user = grant.user

                users << {
                    id:  grant.id,
                    user: {
                        id:    user.id,
                        name:  user.name,
                        email: user.email,
                        city:  user.city,
                        state: user.state,
                        zip:   user.zip,
                        sex:   user.sex,
                    },
                    role:       grant.role.role,  # Sadness.
                    role_id:    grant.role_id,
                    role_label: grant.role.label,
                    owner_type: grant.owner_type,
                    approved:   grant.approved_at.present?,
                }
            end
        end

        success({ users: users.as_json })
        respond
    end


    # POST /authorize/:association_id
    def authorize
        # Requires:  Higher permissions than the association (or Admin)
        #    Input:  association_id
        #  Returns:  updated association

        # Fetch access grant
        grant = ::UserAccess.where(active: true).find(params[:association_id])


        # Deactivate all other access grants at the merchant
        # The user is not be able use lower-access codes, meaning this will only ever revoke lesser (or equal) roles.
        ::UserAccess.where(active: true)  \
            .where(user_id: grant.user_id, owner: grant.owner)  \
            .where.not(id: grant.id)  \
            .update_all(active: false)


        # Approve!
        grant.approved_by = @current_user.id
        grant.approved_at = DateTime.now
        grant.active      = true  # In case future devs break the `update_all` above
        grant.save

        success({ association: as_json_with_role_data(grant) })
        respond
    end


    # DELETE /deauthorize/:association_id
    def deauthorize
        # Requires:  Higher permissions than the association (or Admin)
        #    Input:  association_id
        #  Returns:  updated association

        # Deactivate.
        grant = ::UserAccess.where(active: true).find(params[:association_id])
        grant.active = false
        grant.save

        success({ association: as_json_with_role_data(grant) })
        respond
    end


# eprivate

    def debug_output
        puts "------------------------------------------------------------------------"
        puts "[debug] Headers: "
        # puts request.headers.rack.request.form_hash
        # puts request.headers["rack.request.form_hash"] || "whaaaaaaaaat"
        request.headers.each do |k,v|
            puts " | #{k}: #{v}"
        end
        puts "[debug] Params: "
        pp params
        puts "------------------------------------------------------------------------"
    end

    def verify_owner
        # Verify `owner_id` and `owner_type` exist and point to a valid object
        [:owner_id, :owner_type].each do |param|
            next  if params[param].present?
            fail_web({ msg: "Missing #{param}" })
            return respond
        end

        unless ["Merchant", "Affiliate"].include? params[:owner_type].capitalize
            fail_web({ msg: "Incorrect owner_type. Allowed types: Merchant,Affiliate" })
            return respond
        end

        @owner_id   = params[:owner_id]
        @owner_type = params[:owner_type].capitalize  # aFFILiate -> Affiliate
        @owner      = @owner_type.constantize.where(id: @owner_id).first
        if @owner.nil?
            fail_web({ msg: "Could not find specified #{@owner_type}" })
            return respond
        end

        true
    end

    def user_access_levels
        ##? Should this be a constant?
        [:employee, :manager, :admin]
    end

    def access_level(role)
        user_access_levels.index(role.to_sym)
    end


    def clean_roles
        # if a user has 2+ grants at a merchant, deactivate all but highest
        grants = ::UserAccess.where(active: true).where(user_id: @current_user.id, owner: @owner)

        return true  if grants.empty?

        # Determine the highest access role
        highest_access = nil
        grants.each do |grant|
            if highest_access.nil? || access_level(grant.role.role) > access_level(highest_access.role.role)
                highest_access = grant
            end
        end

        # Deactivate the rest
        grants.where.not(id: highest_access.id).update_all(active: false)

        #TODO: clean affiliate roles as well
    end


    def authenticate_admin
        # Does the user have any access grants?
        grants = ::UserAccess.where(active:true).where(user_id: @current_user.id).where.not(approved_at: nil)
        grants.each do |grant|
            # with sufficient priveleges for the merchant or its affiliate?
            next  unless [:manager, :admin].include? grant.role.role.to_sym  # Terrible.
            return true  if grant.owner == @owner

            # If we're looking at a merchant, look for affiliate-level grants for that merchant, too
            if @owner_type == "Merchant"
                ##Workaround: `Merchant.affiliate` returns nil, even when `Affiliate.find(Merchant.affiliate_id)` does not.
                return true  if @owner.affiliate_id == grant.owner_id && grant.owner_type == "Affiliate"
            end

            # Awesome.
            return true
        end

        fail_web({ msg: "Unauthorized user" })
        return respond
    end


    def verify_sufficient_permissions
        # Verify presence of association
        if params[:association_id].nil? || params[:association_id].empty?
            fail_web({ msg: "Missing association_id" })
            return respond
        end

        grant = ::UserAccess.where(active: true).find(params[:association_id]) || nil
        if grant.nil?
            fail_web({ msg: "Association does not exist" })
            return respond
        end

        # Compare logged in user's grants relevant to the indicated grant (association) and compare the roles.
        user_grant_types = []
        user_grant_types << ::UserAccess.where(active: true).where(user_id: @current_user.id).where(owner: @owner).to_a
        if @owner_type == "Merchant"
            user_grant_types.push ::UserAccess.where(active: true).where(user_id: @current_user.id).where(owner_id: @owner.affiliate_id, owner_type: "Affiliate").to_a
        end
        user_grant_types.reject!{|array| array.empty?}


        # Find the user's highest permissions role
        user_highest_access = -1
        user_grant_types.each do |user_grant_type|
            user_grant_type.each do |user_grant|
                puts "Comparing role: #{user_grant.role.role}"
                puts "Current hightest: #{access_level(user_highest_access) rescue "nil"}"
                user_access = access_level(user_grant.role.role)
                user_highest_access = user_access  if user_access > user_highest_access
            end
        end

        # Admins can approve everything, including other admins.
        return true  if user_highest_role_index == access_level(:admin)
        # Everyone else can approve only the roles below them: Manager->Employee->nothing
        return true  if user_highest_role_index >  access_level(grant.role.role)

        fail_web({ msg: "Insufficient permissions" })
        respond
        false
    end


    def generate_code
        #TODO: generate random phrases, such as: "two distant tortoises" -- "#{number} #{adjective} #{noun(s)}"

        # chars   = ('a'..'z').to_a
        # numeric = (0..9).to_a.map(&:to_s)
        # 0.upto(rand(6..12)) { code += chars.sample   }
        # 0.upto(rand(2..4))  { code += numeric.sample }

        length = 6+rand(4)
        chars  = (('a'..'z').to_a - ['q','o','l']) * 3  # Multiple sets to allow duplicates. Disallow easily-confused chars.
        code   = chars.shuffle[0..length].join

        # Ensure uniqueness
        code = generate_code  if ::UserAccessCode.where(active: true, code: code).count > 0

        code
    end


    def as_json_with_role_data(access_obj)
        unless access_obj.respond_to? :role_id
            raise ArgumentError, "Invalid object passed to Web::V4::AssociationsController#as_json_with_role_data -- must respond to #role_id"
        end
        role = access_obj.role
        json = access_obj.as_json
        json["role"]       = role.role  # Sadness.
        json["role_id"]    = role.id
        json["role_label"] = role.label
        json
    end



end
