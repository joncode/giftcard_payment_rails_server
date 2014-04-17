module CatSetter

    def self.perform
        puts "================== CatSetter::Perform - Current Counts ==================="

        gifts_hash = sorted_gifts_hash_old
        print_counts(gifts_hash)

        puts "================== CatSetter::Perform - Updating Gifts ==================="
        gifts_hash.each do |type_of, gifts|
            gift_ids = []
            gifts.each do |gift|
                update_cats(type_of, gift)
                gift_ids << gift.id
            end
            puts "================== CatSetter::Perform - Updated cat for #{type_of} gifts #{gift_ids}"
        end

        puts "================== CatSetter::Perform - Updated Counts ==================="
        print_counts(sorted_gifts_hash_cat)
    end

    def self.print_counts_old
        gifts_hash = sorted_gifts_hash_old
        print_counts(gifts_hash)
    end

private

    def self.get_gifts
        gifts = Gift.unscoped.all
        puts "Total gifts to start is #{gifts.count}"
        gift
    end

    def self.sorted_gifts_hash_old
        hash = {}
        gifts = self.get_gifts
        non_regifts                   = gifts.where.not(payable_type: "Gift")
        sorted_gifts                  = sort_gifts(non_regifts)
        hash[:gift_admin]             = sorted_gifts[:admin]
        hash[:gift_merchant]          = sorted_gifts[:merchant]
        hash[:gift_user]              = sorted_gifts[:user]
        hash[:gift_campaign_admin]    = sorted_gifts[:campaign_admin]
        hash[:gift_campaign_merchant] = sorted_gifts[:campaign_merchant]

        regifts                         = gifts.where(payable_type: "Gift")
        sorted_regifts                  = sort_gifts(regifts, regift: true)
        hash[:regift_admin]             = sorted_regifts[:admin]
        hash[:regift_merchant]          = sorted_regifts[:merchant]
        hash[:regift_user]              = sorted_regifts[:user]
        hash[:regift_campaign_admin]    = sorted_regifts[:campaign_admin]
        hash[:regift_campaign_merchant] = sorted_regifts[:campaign_merchant]
        hash
    end

    def self.sorted_gifts_hash_cat
        hash = {}
        gifts = self.get_gifts
        hash[:no_cat]                   = gifts.where(cat: [0, nil])
        hash[:gift_admin]               = gifts.where(cat: 100)
        hash[:gift_merchant]            = gifts.where(cat: 200)
        hash[:gift_user]                = gifts.where(cat: 300)
        hash[:gift_campaign_admin]      = gifts.where(cat: 150)
        hash[:gift_campaign_merchant]   = gifts.where(cat: 250)
        hash[:regift_admin]             = gifts.where(cat: 101)
        hash[:regift_merchant]          = gifts.where(cat: 201)
        hash[:regift_user]              = gifts.where(cat: 301)
        hash[:regift_campaign_admin]    = gifts.where(cat: 151)
        hash[:regift_campaign_merchant] = gifts.where(cat: 251)
        hash
    end

    def self.print_counts gifts_hash
        total_gifts = 0
        puts " --- PRINTING GIFT COUNTS ---------------"
        gifts_hash.each do |type_of, gifts|
            print " --- #{type_of}: ".ljust(40, "-")
            puts " #{gifts.length} ".ljust(6, "-")
            total_gifts += gifts.length
        end
            print " --- Total Gifts: ".ljust(40, "-")
            puts " #{total_gifts} ".ljust(6, "-")
    end

    def self.update_cats type_of, gift
        old_cat = gift.cat
        case type_of
        when :gift_admin
            gift.update(cat: 100)
        when :gift_merchant
            gift.update(cat: 200)
        when :gift_user
            gift.update(cat: 300)
        when :gift_campaign_admin
            gift.update(cat: 150)
        when :gift_campaign_merchant
            gift.update(cat: 250)
        when :regift_admin
            gift.update(cat: 101)
        when :regift_merchant
            gift.update(cat: 201)
        when :regift_user
            gift.update(cat: 301)
        when :regift_campaign_admin
            gift.update(cat: 151)
        when :regift_campaign_merchant
            gift.update(cat: 251)
        end
        puts " --- Gift #{gift.id} cat from #{old_cat} to #{gift.cat}"
    end

    def self.sort_gifts gifts, regift=false
        hash = {}
        hash[:admin] = {}
        hash[:merchant] = {}
        hash[:user] = {}
        hash[:campaign_admin] = {}
        hash[:campaign_merchant] = {}
        gifts.each do |gift|
            if regift
                type_of = get_type_of(gift.get_first_regifting_parent)
            else
                type_of = get_type_of(gift)
            end
            hash[type_of] = [] unless hash[type_of].present?
            hash[type_of] << gift
        end
        hash
    end

    def self.get_type_of gift
        case gift.giver_type
        when "AdminGiver"
            :admin
        when "BizUser"
            :merchant
        when "User"
            :user
        when "Campaign"
            case gift.giver.purchaser_type
            when "AdminGiver"
                :campaign_admin
            when "BizUser"
                :campaign_merchant
            end
        end
    end

end