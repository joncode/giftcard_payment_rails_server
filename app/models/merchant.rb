class Merchant < Mtmodel

    has_one :provider

    def mode= mode_str
        case mode_str.downcase
        when "live"
            self.paused = false
            self.live   = true
        when "coming_soon"
            self.paused = false
            self.live   = false
        when "paused"
            self.paused = true
        else
            # cron job to fix the broken mode_str
            puts "#{self.name} #{self.id} was sent mode_str #{mode_str} - update mode broken"
        end
    end

    def get_logo
        if photo_l.present?
            photo_l
        else
            "http://res.cloudinary.com/drinkboard/image/upload/v1408401050/blank_logo_njwzxk.png"
        end
    end

end# == Schema Information
#
# Table name: merchants
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  token       :string(255)
#  zinger      :string(255)
#  description :text
#  active      :boolean         default(TRUE)
#  address     :string(255)
#  address_2   :string(255)
#  city        :string(50)
#  state       :string(2)
#  zip         :string(16)
#  phone       :string(20)
#  email       :string(255)
#  website     :string(255)
#  facebook    :string(255)
#  twitter     :string(255)
#  photo       :string(255)
#  logo        :string(255)
#  rate        :decimal(8, 3)
#  sales_tax   :decimal(8, 3)
#  created_at  :datetime
#  updated_at  :datetime
#  setup       :string(255)     default("000010")
#  image       :string(255)
#  pos         :boolean         default(FALSE)
#  tou         :boolean         default(FALSE)
#  tz          :integer         default(0)
#  live        :boolean         default(FALSE)
#  paused      :boolean         default(TRUE)
#  latitude    :float
#  longitude   :float
#  ein         :string(255)
#

