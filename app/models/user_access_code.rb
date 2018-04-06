class UserAccessCode < ActiveRecord::Base
    belongs_to :owner, polymorphic: true

    def role
        return nil  if self.role_id.nil?
        ::UserAccessRole.find(self.role_id)
    end

    def role=(user_access_role)
        self.role_id = user_access_role.id
    end

    def self.where_role(role)
        case(role)
        when UserAccessRole
            UserAccessCode.where(active:true, role_id:role.id)
        when Fixnum
            UserAccessCode.where(active:true).where(role_id:role)
        when Symbol, String
            ids = UserAccessRole.where(active: true).collect do |uar|
                (uar.role.downcase == role.to_s.downcase ? uar.id : nil)
            end.compact.uniq
            UserAccessCode.where(active:true, role_id:ids)
        else
            nil
        end
    end


    def deactivate!
        self.active = false
        self.save
    end

    # ------------

    include UserAccessHelper

    def level
        access_level(self.role.role)
    end


    # ------------

    def self.for(role:nil, role_id:nil, owner:nil, owner_id:nil, owner_type:nil, moderate:, created_by:nil)
        # Role -> role_id
        if role.present?
            role_id = case(role)
            when UserAccessRole
                role_id = role.id
            when Symbol, String
                role_id = UserAccessRole.where(active: true).where(role: role.to_s.downcase).first.id  rescue nil
            else
                raise ArgumentError, "Expected role of type UserAccessRole or Symbol, got #{role.class}"
            end
        end
        raise ArgumentError, "Role not found"  if role_id.nil?

        # Owner -> id/type
        unless owner.nil?
            owner_type = nil
            owner_type = :merchant  if owner.is_a? Merchant
            owner_type = :affiliate if owner.is_a? Affiliate
            owner_id   = owner.id  rescue nil
            if owner_type.nil?
                raise ArgumentError, "Invalid owner specified. Must be instance of Merchant or Affiliate. Got: #{owner.class}.  Did you mean to use owner_id?"
            end
            if owner_id.nil?
                raise ArgumentError, "No owner_id specified"
            end
        end

        owner_type = owner_type.to_s.capitalize
        unless ["Merchant","Affiliate"].include? owner_type
            raise ArgumentError, "Invalid owner type. Must be Merchant or Affiliate"
        end


        code = self.new
        code.role_id           = role_id
        code.owner_id          = owner_id
        code.owner_type        = owner_type
        code.approval_required = !!moderate
        code.created_by        = created_by
        code.code              = self.generate
        code
    end


    # ------------

    def self.generate(format: nil)

        if format.nil?
            format = [
                # [:three_alpha, :three_alpha],
                [:number, :adjective, :noun],
                [:adjective, :noun],
                # [:number, :noun, :comma, :number, :noun],
                [:number, :noun],
            ].sample
        end

        raise ArgumentError, "Invalid format specified"  unless format.is_a? Array

        code   = []
        number = 1
        code = format.collect do |identifier|
            case(identifier)
            when :three_alpha
                (('a'..'z').to_a*3).shuffle[0..2].join
            when :number
                number = random_number  # For pluralizing the next noun
                number_to_word(number)
            when :adjective
                random_adjective
            when :noun
                word   = random_noun(number)
                number = 1
                word
            when :comma
                ','
            end
        end

        if code.include? :number
            if code.include? :noun
                code[format.index(:noun)] = code[format.index(:noun)].pluralize(number)
            end
        end

        # Join the words, and clean up the :comma entry
        code = code.join(" ").gsub(' ,', ',')

        # Ensure uniqueness
        if UserAccessCode.where(active: true).where(code: code).size > 0
            code = self.generate(format: format)
        end

        code
    end



private

    def self.numbers
        {1000000 => "one million",
            1000 => "one thousand",
             100 => "one hundred",
              90 => "ninety",
              80 => "eighty",
              70 => "seventy",
              60 => "sixty",
              50 => "fifty",
              40 => "forty",
              30 => "thirty",
              20 => "twenty",
              19 => "nineteen",
              18 => "eighteen",
              17 => "seventeen",
              16 => "sixteen",
              15 => "fifteen",
              14 => "fourteen",
              13 => "thirteen",
              12 => "twelve",
              11 => "eleven",
              10 => "ten",
               9 => "nine",
               8 => "eight",
               7 => "seven",
               6 => "six",
               5 => "five",
               4 => "four",
               3 => "three",
               2 => "two",
               1 => "one",
        }
    end

    def self.number_to_word(number)
        self.numbers[number] || number.to_s  # 80 -> "eighty"; 42 -> "42"
    end

    def self.random_number
        num = numbers.keys.sample
    end

    def self.random_adjective
        %w[arrogant angry raging happy sad pretty sizzling steamed steaming
           minced diced boiled boiling cold hot frozen freezing broken bent
           baked peppered flat juicy chipped seared seasoned fried local
           exotic toasted crispy chewy sour sweet salty spicy peeled
           chopped saucy cheesy].sample
    end

    def self.random_noun(count=1)
        %w[beaver badger beehive bishop fish prawn crab shallot pan pot spoon
           fork knife plate napkin chopstick shaker bottle jar glass biscuit pepper
           burger plum apple spork juice chips melon fruit vegetable meat steak
           sushi bread cookie roll cheese carrot pea egg pie pizza blender soup
           wine noodle jam biscuit].sample.pluralize(count)
    end

end
