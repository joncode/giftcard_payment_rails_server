class AdminGiver < Admtmodel
    self.table_name = "users"
    has_many :sent,  as: :giver,  class_name: Gift
    has_many :debts, as: :owner

    def name
        "#{SERVICE_NAME} Staff"
    end

    def get_photo
        "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
    end

    def incur_debt amount
        debt = new_debt(amount)
        debt.save
        debt
    end

    def new_debt amount
        decimal_amount = BigDecimal(amount)
        Debt.new(owner: self, amount: decimal_amount, total: decimal_amount)
    end
end