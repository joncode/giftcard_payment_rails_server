class Web::V4::AssociationsController < MetalCorsController
    before_action :debug_output
    before_action :authentication_token_required, except: [:list_roles]
    before_action :fetch_user, except: [:list_roles]
    before_action :authenticate_admin, only: [ :list_merchant, :new_code, :delete_code, :list_pending, :authorize, :deauthorize ]



    ##@ GET /generate_access_coes
    def debug_generate_codes

        # Verify presence
        if params[:merchant_id].blank?
            fail({ message: "Missing merchant_id" })
            return respond
        end

        codes = []
        ::UserAccessRole.all.each do |role|
            next  if ::UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id], role_id: role.id).count > 0

            code = UserAccessCode.new
            code.role = role
            code.code = generate_code
            code.merchant_id = params[:merchant_id]
            code.save

            codes << code
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
        access_grants = ::UserAccess.where(active: true).where(user_id: @user.id)
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
                id:        grant.id,
                merchant:  merchant,
                affiliate: affiliate,
                type:      type,
                access:    grant.role.id,  # Terrible.
                approved:  grant.approved_at.present?,
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
            fail({ message: "Missing code" })
            return respond
        end


        codes = UserAccessCode.where(active: true).where(code: params[:code])

        if codes.length > 1
            puts "[api v4 Associations :: associate] Warning: There are #{codes.length} UserAccessCodes matching: '#{params[:code]}'"
        end

        # Verify presence
        if codes.empty?
            fail({ message: "No matching code found" })
            return respond
        end

        # While `UserAccessCode.code` should be unique, process all matches.
        grants = []
        codes.each do |code|
            grant = UserAccess.new
            grant.user_id      = user.id
            grant.merchant_id  = code.merchant_id
            grant.affiliate_id = code.affiliate_id
            grant.role_id      = code.role_id
            grant.save

            grants << grant
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
            fail({ message: "Missing merchant_id, affiliate_id; both cannot be blank" })
            return respond
        end
        if association_id.nil?
            fail({ message: "Missing association_id" })
            return respond
        end

        # Fetch UserAccess grant
        # This will locate at most one entry because of the association_id clause
        # Note: as merchant/affiliate id's default to nil, including both clauses isn't an issue
        grant = UserAccess.where(active: true, merchant_id: merchant_id, affiliate_id: affiliate_id).where(id: association_id).first

        if grant.nil?
            fail({ association: nil, message: "No association found" })
            return respond
        end

        # Deactivate UserAccess grant and return it
        grant.active = false
        grant.save

        success({ association: grant.as_json })
        respond
    end



    # GET /:merchant_id
    def list_merchant
        # Requires:  Admin Access
        #    Input:  merchant_id
        #  Returns:  [{id, code, role}, ...]

        success({
            codes: UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id]).as_json
        })
        respond
    end


    # PATCH /:merchant_id/:role_id
    def new_code
        # Requires:  Admin Access
        #    Input:  merchant_id, role_id
        #  Returns:  {id, code, role, active}

        if params[:role_id].empty?
            fail({ message: "Missing role_id" })
            return respond
        end

        role = UserAccessRole.find(params[:role_id])  rescue nil
        unless role.nil?
            fail({ message: "Role not found" })  # Should be a 404
            return respond
        end

        
        code = UserAccessCode.new
        code.role = role
        code.code = generate_code
        code.save

        success({ code: code.as_json })
        respond
    end


    # DELETE /:merchant_id/:code_id
    def delete_code
        # Requires:  Admin Access
        #    Input:  merchant_id, code_id
        #  Returns:  {id, code role, active}

        if params[:code_id].empty?
            fail({ message: "Missing code_id" })
            return respond
        end

        code = UserAccessCode.where(active: true).where(merchant_id: params[:merchant_id], id: params[:code_id]).first
        code.active = false
        code.save

        success({ code: code.as_json })
        respond
    end


    # GET /pending/:merchant_id
    def list_pending
        # Requires:  Admin Access
        #    Input:  merchant_id
        #  Returns:  [{id, user, role_id, type}, ...]

        merchant = Merchant.find(params[:merchant_id])  rescue nil
        if merchant.nil?
            fail({ message: "Unknown merchant" })  # Should be a 404 :/
            return respond
        end


        # Fetch pending grants
        grants = []
        grants.push ::UserAccess.where(active: true).where(affiliate_id: merchant.affiliate_id).where(approved_at: nil).to_a
        grants.push ::UserAccess.where(active: true).where(merchant_id:  params[:merchant_id] ).where(approved_at: nil).to_a
        grants.reject!{ |array| array.empty? }


        # Process pending grants
        pending = []
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
                role:  grant.id,
                type:  type,
            }
        end

        success({ pending: pending.as_json })
        respond
    end


    # POST /authorize/:association_id
    def authorize
        # Requires:  Admin Access
        #    Input:  association_id
        #  Returns:  updated association

        if params[:association_id].empty?
            fail({ message: "Missing association_id" })
            return respond
        end


        grant = ::UserAccess.find(params[:association_id])  rescue nil

        if grant.nil?
            fail({ message: "Could not find association" })  # should be a 404 :/
            return respond
        end

        unless grant.active
            fail({ message: "Association is inactive" })  # should be a 422 :/
            return respond
        end

        # Approve
        grant.approved_by = @user.id
        grant.approved_at = DateTime.now
        grant.save

        success({ associations: grant.as_json })
        respond
    end


    # DELETE /deauthorize/:association_id
    def deauthorize
        # Requires:  Admin Access
        #    Input:  association_id
        #  Returns:  updated association

        if params[:association_id].empty?
            fail({ message: "Missing association_id" })
            return respond
        end

        grant = ::UserAccess.find(params[:association_id])  rescue nil

        if grant.nil?
            fail({ message: "Could not find association" })  # should be a 404
            return respond
        end

        unless grant.active
            fail({ message: "Association is inactive" })  # should be a 422:unprocessable
            return respond
        end

        # Deactivate.
        grant.active = false
        grant.save

        success({ association: grant.as_json })
        respond
    end


private

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


    def fetch_user
        token = request.headers["HTTP_X_AUTH_TOKEN"]
        session = SessionToken.find_by_token(token)  rescue nil
        if session.nil?
            fail({ message: "User not logged in" })
            return respond
        end

        @user = session.user
    end
    

    def authenticate_admin
        # Every action that requires Admin access also requires a merchant_id
        if params[:merchant_id].empty?
            fail({ message: "Missing merchant_id" })
            return respond
        end

        # Does the user have any access grants?
        grants = UserAccess.where(active:true).where(user_id: @user.id)
        grants.each do |grant|
            # with sufficient priveleges for the merchant or its affiliate?
            next  unless [:manager, :admin].include? grant.role.role  # Terrible.
            next  unless grant.merchant_id  == params[:merchant_id]
            next  unless grant.affiliate_id == params[:affiliate_id]

            # Awesome.
            return true
        end

        fail({ message: "Unauthorized user" })
        return respond
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


end
