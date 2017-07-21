class Contact < ActiveRecord::Base
    include Formatters

    belongs_to :brand
    validates :name,   presence: true
    validates :email , presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
    validates :phone , format: { with: VALID_PHONE_REGEX }, uniqueness: true, :if => :phone_exists?
    before_save   :extract_phone_digits       # remove all non-digits from phone

end
# == Schema Information
#
# Table name: contacts
#
#  id         :integer         not null, primary key
#  brand_id   :integer
#  address    :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  name       :string(255)
#  email      :string(255)
#  phone      :string(255)
#  created_at :datetime
#  updated_at :datetime
#


# Contacts
# 		# use current contacts table

# 	add_column :contacts, :status, :string, default: 'live'
# 	add_column :contacts, :active, :boolean, default: true

# 	^^^  put in wrapper methods thru to the CompanyContacts  ^^^

# 		create_table "contacts", force: :cascade do |t|
# 			t.integer  "brand_id"
# 			t.string   "address",    limit: 255
# 			t.string   "city",       limit: 255
# 			t.string   "state",      limit: 255
# 			t.string   "zip",        limit: 255
# 			t.string   "name",       limit: 255
# 			t.string   "email",      limit: 255
# 			t.string   "phone",      limit: 255
# 			t.datetime "created_at"
# 			t.datetime "updated_at"
# 		end
