class Menu < ActiveRecord::Base
    has_many    :menu_items , through: :sections
    has_many    :sections, 	dependent: :destroy
    belongs_to  :owner, polymorphic: true

    validates_presence_of :owner_id, :owner_type

    after_create :make_sections


    MENU_SECTIONS_INIT = ["Gifting Menu", "Gift Vouchers"]

#   -------------

    attr_writer :ccy
    def ccy
        @ccy || self.owner.ccy
    end

#   -------------

    def compile_menu_to_app
        menu_ary = []
        self.sections.each do |section|
            item_ary = section.items_standard.map {|item| item.serialize_to_app }
            if item_ary.count > 0
                menu_ary << {"section" => section.name, "items" => item_ary}
            end
        end
        r = self.update(json: menu_ary.to_json, edited: false)
        # RedisWrap.clear_menu_cache(self.id)
        # logger.info "\nCOMPILE TO APP\n"
        # logger.info r.inspect
        r
    end

    def items_standard
        menu_items.where(standard: true)
    end

    def items_promo
        menu_items.where(promo: true)
    end

    def items_inactive
        menu_items.where(standard: false, promo: false)
    end

    def set_edited
        self.edited = false
    end

    def make_sections
        MENU_SECTIONS_INIT.each_with_index do |section, i|
            Section.create(menu: self, name: section, position: i + 1)
        end
        create_section_specific_menu_items
    end

    def create_section_specific_menu_items
        voucher_section = Section.where(menu_id: self.id, name: "Gift Vouchers").first
        desc = "ItsOnMe digital gifts carry a balance and can be used on multiple visits. Any printed certificate is one-time use only."
        [10,25,50].each do |amt, index|
            MenuItem.create(
                name: "#{CCY[self.ccy]['symbol']}#{amt} gift voucher",
                photo: BLACK_GIFTCARD_IMAGE.sub("|dollaramount|", amt.to_s),
                detail: desc,
                price: amt,
                menu_id: self.id,
                section_id: voucher_section.id,
                position: index,
                standard: true,
                promo: true,
                ccy: self.ccy
            )
        end
    end
end
# == Schema Information
#
# Table name: menus
#
#  id             :integer         not null, primary key
#  merchant_token :string(255)
#  json           :text
#  merchant_id    :integer
#  type_of        :integer
#  edited         :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

# "{\"Signature\":[{\"name\":\"Hurricane Cocktail\",\"description\":\"Lots of different beverages mixed together , deliciously\",\"price\":\"10 \"},{\"name\":\"cool\",\"description\":\"very cold stuff\",\"price\":\"21\"}],\"Beer\":[{\"name\":\"corona\",\"description\":\"mexican beer\",\"price\":\"4\"}],\"Wine\":[{\"name\":\"rothschild\",\"description\":\"windy wino stuff\",\"price\":\"122\"},{\"name\":\"Boorss head\",\"description\":\"meat flavoured wine with ribbs\",\"price\":\"23\"},{\"name\":\"Jennifer\",\"description\":\"convertible sofas as vino\",\"price\":\"22\"}],\"Shot\":[{\"name\":\"jack daniels\",\"description\":\"whiskey is good \",\"price\":\"4\"},{\"name\":\"Johnny Walker black\",\"description\":\"bourbon thats delish\",\"price\":\"21\"},{\"name\":\"whisker 77\",\"description\":\"the good heady stuff\",\"price\":\"33\"}]}"
#		[{"signature":
#  			[{"description":"","item_name":"asdf","photo":null,"price":"12","section":"signature","item_id":1092},
# 			{"description":"","item_name":"test this","photo":null,"price":"13","section":"signature","item_id":1093},
# 			{"description":"","item_name":"another good one","photo":null,"price":"54","section":"signature","item_id":1095},
# 			{"description":"","item_name":"asdf","photo":null,"price":"234","section":"signature","item_id":1102}]},
#        {"beer":
# 			[{"description":"","item_name":"Hello","photo":null,"price":"34","section":"beer","item_id":1091}]},
# 		 {"wine":
# 			[{"description":"","item_name":"Delicious Wine","photo":null,"price":"30","section":"wine","item_id":1088},
# 			{"description":"this is good","id":1090,"item_name":"wineeeoo","photo":null,"price":"23","section":"wine","item_id":1090}]},
# 		 {"shot":
# 			[{"description":"","item_name":"tesret","photo":null,"price":"23","section":"shot","item_id":1089}]}]

#		[{"signature":
#  			[{"description":"","id":1092,"item_name":"asdf","photo":null,"price":"12","section":"signature","menu_item_id":1092},
# 			{"description":"","id":1093,"item_name":"test this","photo":null,"price":"13","section":"signature","menu_item_id":1093},
# 			{"description":"","id":1095,"item_name":"another good one","photo":null,"price":"54","section":"signature","menu_item_id":1095},
# 			{"description":"","id":1102,"item_name":"asdf","photo":null,"price":"234","section":"signature","menu_item_id":1102}]},
#        {"beer":
# 			[{"description":"","id":1091,"item_name":"Hello","photo":null,"price":"34","section":"beer","menu_item_id":1091}]},
# 		 {"wine":
# 			[{"description":"","id":1088,"item_name":"Delicious Wine","photo":null,"price":"30","section":"wine","menu_item_id":1088},
# 			{"description":"this is good","id":1090,"item_name":"wineeeoo","photo":null,"price":"23","section":"wine","menu_item_id":1090}]},
# 		 {"shot":
# 			[{"description":"","id":1089,"item_name":"tesret","photo":null,"price":"23","section":"shot","menu_item_id":1089}]}]

