class PnToken < ActiveRecord::Base

    validates :pn_token, uniqueness: true, length: { minimum: 23 }
    validates_presence_of :user_id

#   -------------

    after_save :register

#   -------------

    belongs_to :user

#   -------------

    def pn_token=(token)
        converted_token = convert_token(token)
        super(converted_token)
    end

#   -------------

    def self.find_or_create_token(user_id, value, platform, device_id=nil)
        canonical_id = nil
        if platform == 'android'
            pnt = PnToken.new(user_id: user_id, pn_token: value, platform: platform.to_s, device_id: device_id)
            canonical_id = OpsPushGoogle.get_canonical_id(pnt)
        end

        puts "PnToken -self.find_or_create_token(#{user_id}, #{value}, #{platform})- "
        value       = self.convert_token(value)

        pn_token = self.find_by(pn_token: value, platform: platform.to_s)
        if pn_token.nil? && canonical_id.present?
            pn_token = self.find_by(canonical_id: canonical_id, platform: platform.to_s)
        end

        if pn_token
            save = false
            if canonical_id.present? && pn_token.canonical_id.nil?
                pn_token.canonical_id = canonical_id
                save = true
            end
            if device_id.present? && pn_token.device_id.nil?
                pn_token.device_id = device_id
                save = true
            end
            if pn_token.user_id != user_id
                pn_token.user_id = user_id
                save = true
            end
            pn_token.save if save
            pn_token
        else
            PnToken.create(
                user_id: user_id,
                pn_token: value,
                platform: platform.to_s,
                device_id: device_id,
                canonical_id: canonical_id
            )
        end
    end

    def self.convert_token(token)
        token.gsub('<','').gsub('>','').gsub(' ','')
    end

#   -------------


    def convert_token(token)
        token.gsub('<','').gsub('>','').gsub(' ','')
    end

    def ua_alias
            # move this to pn_token.rb
        adj_user_id = self.user_id + NUMBER_ID
        "user-#{adj_user_id}"
    end

private

    def register
        if !Rails.env.test?
            Resque.enqueue(RegisterPushJob, self.id)
        else
            RegisterPushJob.perform(self.id)
        end
    end

end

# Mar 17 01:39:37 dbappdev app/web.1:  MDOT/V2/SESSIONS -CREATE- request: {"email"=>"joe.meeks@sos.me", "password"=>"joem420", "pn_token"=>"APA91bEYOma7M6bqiBz8TGdjke420-fpYHx29NZKSVX-S2_kI1gpYbTP1sSCgSBZR8o42YZh5KrkQgEXUCI4d6DgXAs1m1tY36D-VPZvzLOx9rePwaDmGRfYmKaL3IQc1T6FEp0JEphK"}
# Mar 17 01:39:41 dbappdev app/worker.1:  registering PN Token for Joe Meeks
# Mar 17 01:39:42 dbappdev app/worker.1:  Urbanairship (81ms): [Put /api/device_tokens/APA91bEYOma7M6bqiBz8TGdjke420-fpYHx29NZKSVX-S2_kI1gpYbTP1sSCgSBZR8o42YZh5KrkQgEXUCI4d6DgXAs1m1tY36D-VPZvzLOx9rePwaDmGRfYmKaL3IQc1T6FEp0JEphK, {"alias":"user-649452"}], [400, {"error_code":40001,"details":{"device_token":["device_token contains an invalid device token: APA91bEYOma7M6bqiBz8TGdjke420-fpYHx29NZKSVX-S2_kI1gpYbTP1sSCgSBZR8o42YZh5KrkQgEXUCI4d6DgXAs1m1tY36D-VPZvzLOx9rePwaDmGRfYmKaL3IQc1T6FEp0JEphK"]},"error":"Data validation error"}]
# Mar 17 01:39:42 dbappdev app/worker.1:  UA response --- >  {"error_code"=>40001, "details"=>{"device_token"=>["device_token contains an invalid device token: APA91bEYOma7M6bqiBz8TGdjke420-fpYHx29NZKSVX-S2_kI1gpYbTP1sSCgSBZR8o42YZh5KrkQgEXUCI4d6DgXAs1m1tY36D-VPZvzLOx9rePwaDmGRfYmKaL3IQc1T6FEp0JEphK"]}, "error"=>"Data validation error"}
# == Schema Information
#
# Table name: pn_tokens
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  pn_token   :string(255)
#  platform   :string(255)     default("ios")
#  created_at :datetime
#  updated_at :datetime
#

