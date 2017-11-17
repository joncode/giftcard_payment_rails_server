class ProtoJoin < ActiveRecord::Base
	include MoneyHelper


	validates_presence_of :proto_id, :receivable_id, :receivable_type
	validates :proto_id, :uniqueness => { scope: [:receivable_id, :receivable_type, :gift_id] }, if: :proto_not_camp?
	validates :proto_id, :uniqueness => { scope: [:receivable_id, :receivable_type] }, if: :proto_camp?
	validates_uniqueness_of :gift_id, allow_nil: true

#   -------------

	belongs_to :gift
	belongs_to :receivable, polymorphic: true
	belongs_to :proto

#   -------------

	def self.create_with_proto_and_rec(proto, rec)
		create(proto_id: proto.id,
			receivable_type: rec.class.to_s,
			receivable_id: rec.id,
			rec_name: rec.name)
	end

	def convert_to_gift_receiver(args)
		receiver = self.receivable
		receiver = receiver.user if receiver.kind_of?(UserSocial)
		args['receiver_name'] = self.rec_name
		args['receiver_name'] = receiver.name if args['receiver_name'].blank?
		if receiver.kind_of?(User)
			# set the name and the id
			args['receiver_id']   = receiver.id
		elsif receiver.kind_of?(Social)
			# set the name and the correct args key
			case receiver.network
			when 'email'
				args['receiver_email'] = receiver.network_id
				args['receiver_name'] = receiver.network_id if args['receiver_name'].blank?
			when 'phone'
				args['receiver_phone'] = receiver.network_id
				args['receiver_name'] = number_to_phone(receiver.network_id) if args['receiver_name'].blank?
			when 'facebook_id'
				args['facebook_id'] = receiver.network_id
			when 'facebook'
				args['facebook_id'] = receiver.network_id
			when 'twitter'
				args['twitter'] = receiver.network_id
			end
		end
		args['receiver_name'] = GENERIC_RECEIVER_NAME if args['receiver_name'].blank?
		args
	end

private

	def proto_not_camp?
		self.proto && !self.proto.camp && !self.proto.bonus
	end

	def proto_camp?
		self.proto && self.proto.camp
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

