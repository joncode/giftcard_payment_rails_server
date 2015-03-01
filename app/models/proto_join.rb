class ProtoJoin < ActiveRecord::Base

	belongs_to :gift
	belongs_to :receivable, polymorphic: true
	belongs_to :proto

	validates :proto_id, :uniqueness => { scope: [:receivable_id, :receivable_type, :gift_id] }
	validates_uniqueness_of :gift_id, allow_nil: true

	def convert_to_gift_receiver(args)
		receiver = self.receivable
		if receiver.kind_of?(User)
			# set the name and the id
			args["receiver_name"] = receiver.name
			args["receiver_id"]   = receiver.id
		elsif receiver.kind_of?(Social)
			# set the name and the correct args key
			case receiver.network
			when 'email'
				args['receiver_email'] 	= receiver.network_id
			when 'phone'
				args['receiver_phone'] 	= receiver.network_id
			when 'facebook_id'
				args['facebook_id'] 	= receiver.network_id
			when 'facebook'
				args['facebook_id'] 	= receiver.network_id
			when 'twitter'
				args['twitter'] 		= receiver.network_id
			end
		elsif  receiver.kind_of?(UserSocial)
			# set the name and and the receiver id
			user = receiver.user
			args["receiver_name"] = user.name
			args["receiver_id"]   = user.id
		end

	end
end
# == Schema Information
#
# Table name: proto_joins
#
#  id              :integer         not null, primary key
#  proto_id        :integer
#  receivable_id   :integer
#  receivable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  gift_id         :integer
#  rec_name        :string(255)
#

