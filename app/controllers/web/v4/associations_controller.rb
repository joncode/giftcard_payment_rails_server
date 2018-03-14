class Web::V4::AssociationsController < MetalCorsController
    before_action :debug_output
    before_action :authentication_token_required, except: [:list_roles]
    before_action :authenticate_admin, only: [:list_merchant, :new_code, :delete_code, :list_pending, :list_merchant_users]
    before_action :verify_sufficient_permissions, only: [:authorize, :deauthorize]



    ##@ GET /generate_access_coes
    def debug_generate_codes

        # Verify presence
        if params[:merchant_id].blank?
            fail_web({ msg: "Missing merchant_id" })
            return respond
        end

        codes = []
        ::UserAccessRole.all.each do |role|
            next  if ::UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id], role_id: role.id).count > 0

            code = ::UserAccessCode.new
            code.role = role
            code.code = generate_code
            code.merchant_id = params[:merchant_id]
            code.save

            codes << as_json_with_role_data(code)
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

            type = nil
            type = :merchant  if grant.merchant_id.present?
            type = :affiliate if grant.affiliate_id.present?

            # Catch malformed access grants
            if type.nil?
                puts "[api v4 Associations::list_user] Warning: UserAccess[#{grant.id}] has neither a linked merchant nor association."
                # and skip them
                next
            end

            merchant = nil
            if grant.merchant_id.present?
                merchant = {
                    id:        grant.merchant.id,
                    name:      grant.merchant.name,
                    address:   grant.merchant.address,
                    address_2: grant.merchant.address_2,
                    city_name: grant.merchant.city_name,
                    state:     grant.merchant.state,
                    zip:       grant.merchant.zip,
                    photo:     grant.merchant.photo,
                    photo_l:   grant.merchant.photo_l,
                    r_sys:     grant.merchant.r_sys,
                    hex_id:    grant.merchant.hex_id,
                    active:    grant.merchant.active,
                }
            end

            affiliate = nil
            if grant.affiliate_id.present?
                affiliate = {
                    id:        grant.affiliate.id,
                    name:      grant.affiliate.name,
                    address:   grant.affiliate.address,
                    city_name: grant.affiliate.city_name,
                    state:     grant.affiliate.state,
                    zip:       grant.affiliate.zip,
                    phone:     grant.affiliate.phone,
                    url_name:  grant.affiliate.url_name,
                }
            end


            associations << {
                id:         grant.id,
                merchant:   merchant,
                affiliate:  affiliate,
                type:       type,
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


        codes = UserAccessCode.where(active: true).where(code: params[:code])

        if codes.length > 1
            puts "[api v4 Associations :: associate] Warning: There are #{codes.length} UserAccessCodes matching: '#{params[:code]}'"
        end

        # Verify presence
        if codes.empty?
            fail_web({ msg: "No matching code found" })
            return respond
        end

        # While `UserAccessCode.code` should be unique, process all matches.
        grants = []
        codes.each do |code|
            grant = UserAccess.new
            grant.user_id      = @current_user.id
            grant.merchant_id  = code.merchant_id
            grant.affiliate_id = code.affiliate_id
            grant.role_id      = code.role_id
            grant.approved_at  = DateTime.now  unless code.approval_required
            grant.save

            # Pass the Role data to the client
            grants << as_json_with_role_data(grant)
        end


        success({ associations: grants.as_json })
        return respond
    end


    # DELETE /
    def disassociate
        # Input:    merchant_id, affiliate_id, association_id
        # Returns:  updated association object

        merchant_id    = params[:merchant_id]
        affiliate_id   = params[:affiliate_id]
        association_id = params[:association_id]
        
        merchant_id    = nil  if merchant_id.blank?
        affiliate_id   = nil  if affiliate_id.blank?
        association_id = nil  if association_id.blank?


        if merchant_id.nil? && affiliate_id.nil?
            fail_web({ msg: "Missing merchant_id, affiliate_id; both cannot be blank" })
            return respond
        end
        if association_id.nil?
            fail_web({ msg: "Missing association_id" })
            return respond
        end

        # Fetch UserAccess grant
        # This will locate at most one entry because of the association_id clause
        # Note: as merchant/affiliate id's default to nil, including both clauses isn't an issue
        grant = UserAccess.where(active: true, merchant_id: merchant_id, affiliate_id: affiliate_id).where(id: association_id).first

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



    # GET /:merchant_id
    def list_merchant
        # Requires:  Admin Access
        #    Input:  merchant_id
        #  Returns:  [{id, code, role}, ...]

        codes = []
        # ::UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id]).map(&:as_json_with_role_data)  # ?
        ::UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id]).each do |code|
            codes << as_json_with_role_data(code)
        end

        success({
            codes: codes.as_json
        })
        respond
    end


    # PATCH /:merchant_id/:role_id
    def new_code
        # Requires:  Admin Access
        #    Input:  merchant_id, role_id
        #  Returns:  {id, code, role, active}

        if params[:role_id].empty?
            fail_web({ msg: "Missing role_id" })
            return respond
        end

        role = UserAccessRole.find(params[:role_id])  rescue nil
        unless role.nil?
            fail_web({ msg: "Role not found" })  # Should be a 404
            return respond
        end

        
        code = UserAccessCode.new
        code.role = role
        code.code = generate_code
        code.save

        success({ code: as_json_with_role_data(code) })
        respond
    end


    # DELETE /:merchant_id/:code_id
    def delete_code
        # Requires:  Admin Access
        #    Input:  merchant_id, code_id
        #  Returns:  {id, code role, active}

        if params[:code_id].empty?
            fail_web({ msg: "Missing code_id" })
            return respond
        end

        code = UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id], id: params[:code_id]).first
        code.active = false
        code.save

        success({ code: as_json_with_role_data(code) })
        respond
    end


    # GET /pending/:merchant_id
    def list_pending
        # Requires:  Admin Access
        #    Input:  merchant_id
        #  Returns:  [{id, user, role_id, type}, ...]

        merchant = Merchant.find(params[:merchant_id])  rescue nil
        if merchant.nil?
            fail_web({ msg: "Unknown merchant" })  # Should be a 404 :/
            return respond
        end


        # Fetch pending grants
        types = []
        types.push ::UserAccess.where(active: true, approved_at: nil).where(affiliate_id: merchant.affiliate_id).where.not(affiliate_id: nil).to_a
        types.push ::UserAccess.where(active: true, approved_at: nil).where(merchant_id:  params[:merchant_id] ).where.not(merchant_id: nil).to_a
        types.reject!{ |array| array.empty? }


        # Process pending grants
        pending = []
        types.each do |grants|
            grants.each do |grant|
                user = grant.user

                type = :merchant   if grant.merchant_id.present?
                type = :affiliate  if grant.affiliate_id.present?

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
                    type:       type,
                }
            end
        end

        success({ pending: pending.as_json })
        respond
    end


    # GET /users/:merchant_id
    def list_merchant_users
        merchant = Merchant.find(params[:merchant_id])  rescue nil
        if merchant.nil?
            fail_web({ msg: "Unknown merchant" })  # Should be a 404 :/
            return respond
        end


        # Fetch all grants
        types = []
        types.push ::UserAccess.where(active: true).where(affiliate_id: merchant.affiliate_id).where.not(affiliate_id: nil).to_a
        types.push ::UserAccess.where(active: true).where(merchant_id:  params[:merchant_id] ).where.not(merchant_id: nil).to_a
        types.reject!{ |array| array.empty? }


        # Process grants
        users = []
        types.each do |grants|
            grants.each do |grant|
                user = grant.user

                type = :merchant   if grant.merchant_id.present?
                type = :affiliate  if grant.affiliate_id.present?

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
                    type:       type,
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

        # Approve!
        grant = ::UserAccess.where(active: true).find(params[:association_id])
        grant.approved_by = @current_user.id
        grant.approved_at = DateTime.now
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


    def authenticate_admin
        # Every action that requires Admin access also requires a merchant_id
        if params[:merchant_id].nil? || params[:merchant_id].empty?
            fail_web({ msg: "Missing merchant_id" })
            return respond
        end

        # Does the user have any access grants?
        grants = UserAccess.where(active:true).where(user_id: @current_user.id).where.not(approved_at: nil)
        grants.each do |grant|
            # with sufficient priveleges for the merchant or its affiliate?
            next  unless [:manager, :admin].include? grant.role.role.to_sym  # Terrible.
            next  unless grant.merchant_id.to_s  == params[:merchant_id].to_s.strip   # (Make sure we're only comparing
            next  unless grant.affiliate_id.to_s == params[:affiliate_id].to_s.strip  #  strings, not ints or nils)

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
        merchant_id  = grant.merchant_id
        affiliate_id = grant.affiliate_id
        type = :merchant   if merchant_id
        type = :affiliate  if affiliate_id


        user_grant_types = []
        user_grant_types << ::UserAccess.where(active: true).where(user_id: @current_user.id).where( merchant_id: merchant_id ).where.not( merchant_id: nil)
        user_grant_types << ::UserAccess.where(active: true).where(user_id: @current_user.id).where(affiliate_id: affiliate_id).where.not(affiliate_id: nil)
        user_grant_types.reject!{|array| array.empty?}


        # Find the user's highest permissions role
        roles = [:employee, :manager, :admin]
        user_highest_role_index = -1
        user_grant_types.each do |user_grant_type|
            user_grant_type.each do |user_grant|
                puts "Comparing role: #{user_grant.role.role}"
                puts "Current hightest: #{roles[user_highest_role_index] rescue "nil"}"
                user_grant_index = roles.index(user_grant.role.role.to_sym)
                user_highest_role_index = user_grant_index  if user_grant_index > user_highest_role_index
            end
        end

        grant_role_index = roles.index(grant.role.role.to_sym)
        admin_role_index = roles.index(:admin)
        # Admins can approve everything, including other admins.
        if (user_highest_role_index != admin_role_index)
            # Everyone else can approve only the roles below them: Manager->Employee->nothing
            if (user_highest_role_index < grant_role_index)
                fail_web({ msg: "Insufficient permissions" })
                return respond
            end
        end

        true
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
        code = generate_code  if UserAccessCode.where(code: code).count > 0

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
