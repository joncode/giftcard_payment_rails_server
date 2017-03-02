class Section < ActiveRecord::Base

    default_scope -> { order(position: :asc)}

#	-------------

    before_validation(:on => :create) { set_position }

#	-------------

    validates_presence_of :menu_id, :position, :name

#	-------------

    before_save :limit_position

    before_update :re_order_sections!

    before_destroy :remove_position

#	-------------

    has_many   :menu_items, dependent: :destroy

    belongs_to :menu

#	-------------

	def self.get_voucher(menu_id)
		section = where(menu_id: menu_id, name: 'Gift Vouchers').first
		if section.nil?
			Section.create(menu_id: menu_id, name: 'Gift Vouchers')
		else
			section
		end
	end

#	-------------

    def deletable
        count1 = self.menu_items.count
        count2 = self.menu_items.where(active: false).count
        !(count1 > 0 || count2 > 0)
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


private


    def re_order_sections!
        position_increased = position_was > position
        position_range     = position_increased ? position..position_was : position_was.. position

        sections = menu.sections.where(position: position_range).where.not(id: self)
        sections.each do |s|
            change_by = position_increased ? 1 : -1
            s.update_columns(position: s.position + change_by)
        end
    end

    def limit_position
        total = Section.where(menu_id: self.menu_id).count
        if self.position > total + 1
            self.position = total
        end
    end

    def remove_position
        # when you destroy a section - remove that position and move higher ones down by 1
        sections    = Section.where(menu_id: self.menu_id)
        position    = self.position
        sections.each do |section|
            if section.position > position
                new_pos = section.position - 1
                section.update(position: new_pos)
            end
        end
    end

    def set_position
        # get all the sections for the proposed menu
        # count them - count is already the correct index for the new section
        if position.blank?
            self.position = Section.where(menu: menu).count + 1
        end
    end


end