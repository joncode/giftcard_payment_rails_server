class Web::V4::AssociationsController < MetalCorsController
    before_action :authentication_token_required
    before_action :authenticate_admin, only: [ :list_merchant, :new_code, :delete_code, :list_pending, :authorize, :deauthorize ]


    # GET /
    def list_user
        # Returns:  user_access_id, merchant, access type, access role, approval status
        associations = []
        roles = ::UserAccessRole.pluck :role

        # 1..5 Sample associations
        0.upto(rand(1..5)) do |id|
            merchant = Merchant.where(active: true).sample

            associations << {
                id:       id,
                merchant: {
                    id:        merchant.id,
                    name:      merchant.name,
                    address:   merchant.address,
                    address_2: merchant.address_2,
                    city_name: merchant.city_name,
                    state:     merchant.state,
                    zip:       merchant.zip,
                    photo:     merchant.photo,
                    photo_l:   merchant.photo_l,
                    r_sys:     merchant.r_sys,
                    hex_id:    merchant.hex_id,
                    active:    merchant.active,
                },
                type:     [:merchant, :affiliate].sample,
                access:   roles.sample,
                approved: [true, false].sample
            }
        end
        success({associations: associations.shuffle})
        respond
    end


    # POST /:merchant_id
    def associate
        #    Input:  user_access_code
        #  Actions:  Push notification and or email to admins of pending access grant
        success({ message: "Associate: Recieved, but not actually accepting data" })
        respond
    end


    # DELETE /:merchant_id
    def disassociate
        # Input:  merchant_id, role
        success({ message: "Disassociate: Recieved, but not actually accepting data" })
        respond
    end


    # GET /:merchant_id
    def list_merchant
        # Requires:  Admin Access
        #    Input:  merchant_id
        #  Returns:  user_access_code_id, code, role

        roles   = UserAccessRole.pluck :role

        codes = []
        0.upto(2) do |id|
            codes << {
                id:   id,
                code: fake_code,
                role: roles[id]
            }
        end

        success({codes: codes.shuffle})
        respond
    end


    # PATCH /:merchant_id/role
    def new_code
        # Requires:  Admin Access
        #    Input:  merchant_id, role
        #  Returns:  user_access_code_id, code, role
        success({
            id:   0,
            code: fake_code,
            role: UserAccessRole.pluck(:role).sample,
            message: "New code: Recieved, but not actually accepting data",
        })
        respond
    end


    # DELETE /:merchant_id/:user_access_code_id
    def delete_code
        # Requires:  Admin Access
        #    Input:  merchant_id, user_access_code_id
        success({ message: "Delete code: Recieved, but not actually accepting data" })
        respond
    end


    # GET /pending/:merchant_id
    def list_pending
        # Requires:  Admin Access
        #    Input:  merchant_id
        #  Returns:  user_access_id, user data, code, role, type

        roles = ::UserAccessRole.pluck :role

        pending = []
        1.upto(rand(0..5)) do |id|
            user = User.where(active: true).sample

            pending << {
                id:  id,
                user: {
                    id:    user.id,
                    name:  user.name,
                    email: user.email,
                    city:  user.city,
                    state: user.state,
                    zip:   user.zip,
                    sex:   user.sex
                },
                code:  fake_code,
                role:  roles.sample,
                type:  [:merchant, :affiliate].sample
            }
        end

        # raise RuntimeError, "[Web::V4::AssociationsController :: list_pending]"
        # raise NotImplementedError, pending
        success({pending: pending.shuffle})
        respond
    end


    # POST /authorize/:user_access_id
    def authorize
        # Requires:  Admin Access
        #    Input:  user_access_id
        success({ message: "Authorize: Recieved, but not actually accepting data" })
        respond
    end


    # DELETE /deauthorize/:user_access_id
    def deauthorize
        # Requires:  Admin Access
        #    Input:  user_access_id
        success({ message: "Deauthorize: Recieved, but not actually accepting data" })
        respond

    end


private

    def authenticate_admin
        true
    end

    
    def fake_code
        chars   = ('a'..'z').to_a
        numeric = (0..9).to_a.map(&:to_s)

        code = ""
        # ['a'..'z', 0..9].map(&:to_a).flatten
        0.upto(rand(4..8)) { code += chars.sample   }
        0.upto(rand(2..4)) { code += numeric.sample }

        code
    end


end
