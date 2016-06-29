module CardTesters
    extend ActiveSupport::Concern


    def tvisa
    	Card.new(zip: '90036', number: '4111111111111111', csv: '186',name: 'Test Visa', nickname: 'Test Visa', month: DateTime.now.month, year: DateTime.now.year )
    end

    def hvisa
    	card_hsh = {}
		card_hsh["first_name"] = 'Tester'
		card_hsh["last_name"] = 'VisaCard'
		card_hsh["number"] = '4111111111111111'
		card_hsh["month"] = DateTime.now.month
		card_hsh["year"] = DateTime.now.year
        card_hsh["cvv"] = '186'
		card_hsh["brand"] = 'visa'
		card_hsh
    end

    def tmaster
    	Card.new(zip: '90036', number: '5555555555554444', csv: '200',name: 'Test Master', nickname: 'Test Master', month: DateTime.now.month, year: DateTime.now.year )
    end

    def hmaster
    	card_hsh = {}
		card_hsh["first_name"] = 'Tester'
		card_hsh["last_name"] = 'Master'
		card_hsh["number"] = '5555555555554444'
		card_hsh["month"] = DateTime.now.month
		card_hsh["year"] = DateTime.now.year
        card_hsh["cvv"] = '200'
		card_hsh["brand"] = 'master'
		card_hsh
    end

    def tamex
    	Card.new(zip: '90036', number: '378282246310005', csv: '4242',name: 'Test AmEx', nickname: 'Test AmEx', month: DateTime.now.month, year: DateTime.now.year )
    end

    def hamex
    	card_hsh = {}
		card_hsh["first_name"] = 'Tester'
		card_hsh["last_name"] = 'Amex'
		card_hsh["number"] = '378282246310005'
		card_hsh["month"] = DateTime.now.month
		card_hsh["year"] = DateTime.now.year
        card_hsh["cvv"] = '4242'
		card_hsh["brand"] = 'amex'
		card_hsh
    end

    # def tjcb
    # 	Card.new(zip: '90036', number: '4111111111111111', csv: '186', nickname: 'Test Visa', brand: 'visa', month: DateTime.now.month, year: DateTime.now.year )

    # end

    # def tdisc
    # 	Card.new(number: '4111111111111111', csv: '186', nickname: 'Test Visa', brand: 'visa', month: DateTime.now.month, year: DateTime.now.year )

    # end

    # def tdclub
    # 	Card.new(number: '4111111111111111', csv: '186', nickname: 'Test Visa', brand: 'visa', month: DateTime.now.month, year: DateTime.now.year )

    # end


end




# Visa	4111111111111111	Expiry Date: Any future date.
# MasterCard	5500000000000004	Expiry Date: Any future date.
# American Express	340000000000009 ***Note: Amex is 15 characters	Expiry Date: Any future date.
# JCB	3566002020140006	Expiry Date: Any future date.
# Discover	6011000000000004	Expiry Date: Any future date.
# Diners Club	36438999960016	Expiry Date: Any future date.