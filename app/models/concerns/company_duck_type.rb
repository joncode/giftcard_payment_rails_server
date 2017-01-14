module CompanyDuckType
    extend ActiveSupport::Concern

    included do
        has_many :clients,     as: :partner
        has_many :invites,  as: :company
        has_many :mt_users, through: :invites

        belongs_to :bank
        belongs_to :menu
        belongs_to :promo_menu
    end

    def write_menu_access?
        menu.blank? || menu.owner_id == id
    end

    def create_menu
        menu = MenuFull.create(owner_id: self.id, owner_type: self.class.to_s)
        if menu.persisted?
            self.update(menu_id: menu.id)
            menu
        else
        	menu
        end
    end

    def time_zone
        TIME_ZONES[self.tz]
    end

    alias_method :timezone, :time_zone

    def venue_name
        name
    end
end
