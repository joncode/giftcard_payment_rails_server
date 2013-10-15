class AdminUser < Admtmodel
    self.table_name = "users"

    def name
        if self.last_name.blank?
          "#{self.first_name}"
        else
          "#{self.first_name} #{self.last_name}"
        end
    end

end