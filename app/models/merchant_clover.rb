class MerchantClover
    extend Emailer

	def self.make signup

		puts "\n\n MerchantClover MAKE \n\n"

		m = init(signup)
		if m.save
			if Rails.env.development?
				ListByStateMakerJob.perform
			else
				Resque.enqueue(ListByStateMakerJob)
			end
			signup.update(merchant_id: m.id)
			l = License.clover_license(m)
			if l.save
				i = Invite.new_invite(m, m.signup_email)
				if i.save
					puts "\n\n\nsend_comprehensive_setup_email(m)"
					puts m.inspect
					puts "\n\n\n"
					# add auto merchant to the metro area lists that are appropriate
					# add the city ID if necessary
					# bust the cache and add merchant to WBG
					# default banner photo for the auto-created merchants
					h = {}
					h['token'] = i.invite_tkn
					h['email'] = i.email
					h['merchant_id'] = i.company_id
					merchant_invite(h)
				else
					# invite not persisted
					puts "MerchantClover 30 - invite failure"
					puts i.errors.full_messages
				end
			else
				# license not persisted
				puts "MerchantClover 35 - license failure"
				puts l.errors.full_messages
			end
		else
			# merchant not persisted
			puts "MerchantClover 40 - merchant failure"
			puts m.errors.full_messages
		end
		m
	end

	def self.init signup
		m = Merchant.new
		m.name = signup.data['name']
		m.phone = signup.data['phone']
		m.email = signup.data['email']
		m.signup_email = signup.data['email']
		m.website = signup.data['website']
		m.address = signup.data['address1'].titleize if signup.data['address1'].kind_of(String)
		m.address_2 = signup.data['address2']
		m.city_name = signup.data['city'].titleize if signup.data['city'].kind_of(String)
		m.state = signup.data['state']
		m.zip = signup.data['zip']
		m.ccy = signup.data['ccy']
		m.tz = generate_timzone_for(signup.data['time_zone'])
		m.pos_merchant_id = signup.data['pos_merchant_id']
		m.r_sys = 7
		m.paused = false
		m.live = true
		m.active = true
		m.rate = '95'
		m.pos_sys = 'Clover'
		m.tou = true
		m.photo = MERCHANT_BANNER_IMAGES.sample
		m
	end

	def self.generate_timzone_for tz
		if tz.match /pacific/i
			return 0
		elsif tz.match /mountain/i
			return 1
		elsif tz.match /eastern/i
			return 3
		elsif tz.match /central/i
			return 2
		end
	end
end



__END__

def merchant_params
    params.require(:data).permit(:building_id, :ccy, :menu_id, :client_id, :affiliate_id, :photo, :photo_l, :pos_sys, :signup_email,
        :signup_name, :website, :tender_type_id, :rate, :name, :phone, :address, :city, :state, :tz, :zip, :region_id,
        :city_id, :zinger, :description, :pos_merchant_id, :account_admin_id)
end


- merchant (attach to merchant signup)
	- generate :menu, :section for vouchers, :menu_items 3 vouchers with images
	- add merchant to lists (state, metro_area)
	- generate license , clover type
	- generate invite and send email for MtUser account creation
	- generate gift button widget, FB widget
- send email with
	- invite to MT
	- widget instructions
	- link to WBG page locations
	- training video instructions
	- banner / logo upload instructions
	- make your own menu item instructions
	- how to make a promo gift instructions


#<MerchantSignup id: 27, name: "ItsOnMe Test Merchant", position: "CloverPOS",
email: "richard1@rangerllt.com", phone: "702-555-1212", website: "https://www.itson.me",
venue_name: "ItsOnMe Test Merchant", venue_url: "https://www.itson.me",
point_of_sale_system: "clover", message: "Clover Machine Initialized - Signup Requested",
created_at: "2017-03-01 21:09:52", updated_at: "2017-03-01 21:09:52", active: true,
address: "123 Mockingbird Lane", merchant_id: nil, pos_merchant_id: "J4Q1V4P5X0KS0",
device_id: "74e6a379-9a1f-4511-ac6c-96e4b54c10b8",
data: {"zip"=>"89101",
	"phone"=>"702-555-1212",
	"website"=>"https://www.itson.me",
	"locale"=>"en_US", "state"=>"NV",
	"vat"=>false, "address1"=>"123 Mockingbird Lane", "address2"=>"Apt 2b",
	"device_id"=>"74e6a379-9a1f-4511-ac6c-96e4b54c10b8",
	"address3"=>"", "support_email"=>"dev@clover.com",
	"city"=>"Las Vegas", "currency"=>"USD", "id"=>"J4Q1V4P5X0KS0",
	"time_zone"=>"Pacific Standard Time", "email"=>"richard1@rangerllt.com",
	"support_phone"=>"(000) 000-0000", "name"=>"ItsOnMe Test Merchant",
	"account"=>"Account {name=ItsOnMe Test Merchant | richard1@rangerllt.com (DEV), type=com.clover.account}",
	"mid"=>"RCTST0000008099", "serial_number"=>"C010UQ61030017",
	"pos_merchant_id"=>"J4Q1V4P5X0KS0", "ccy"=>"USD"}>




<Invite id: 341, invite_tkn: "EzP7lxYKhs40ZUFYgjPw1A", email: "kyle@objectstudio.co", mt_user_id: nil,
company_id: 42, active: true, rank: 0, general: false, created_at: "2017-01-25 23:23:45",
updated_at: "2017-01-25 23:23:45", company_type: "Merchant">









