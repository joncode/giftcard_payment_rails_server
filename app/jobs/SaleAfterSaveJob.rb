class SaleAfterSaveJob
    @queue = :aafter_save


    def self.perform sale_id

    	sale = Sale.find(sale_id)
    	sale.set_and_save_usd_cents

    end


end