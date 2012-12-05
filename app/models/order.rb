# == Schema Information
#
# Table name: orders
#
#  id          :integer         not null, primary key
#  redeem_id   :integer
#  gift_id     :integer
#  redeem_code :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  server_code :string(255)
#  server_id   :integer
#  provider_id :integer
#  employee_id :integer
#

class Order < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :redeem_id, :server_code, :server_id, :provider_id, :employee_id
  
  belongs_to  :provider
  belongs_to  :redeem
  belongs_to  :gift
  belongs_to  :employee
  belongs_to  :sales
  belongs_to  :cards
  belongs_to  :server, class_name: "User"    #  be class_name "Employee"

  # order must be unique for each gift and redeem 
        # validation for provider_id is in callback until data is being sent from iPhone
  validates_presence_of :employee_id 
  validates :gift_id   , presence: true, uniqueness: true
  validates :redeem_id , presence: true, uniqueness: true
    
  before_validation :add_gift_id,     :if => :no_gift_id
  before_validation :get_employee_id
  before_validation :add_redeem_id,   :if => :no_redeem_id
  before_validation :add_provider_id, :if => :no_provider_id
  before_validation :authenticate_via_code
  after_create      :update_gift_status
    
  private
    
    def add_server
      server_ary      = self.provider.get_server_from_code(self.server_code)
      server_obj      = server_ary.pop
      self.server_id  = server_obj.user.id
      puts "found server #{server_obj.name} #{server_obj.id}" 
    end

    def update_gift_status
      self.gift.update_attribute(:status, 'redeemed')
      puts "UPDATE GIFT STATUS #{self.gift.status}"
    end
    
    def authenticate_via_code
      puts "AUTHENTICATE VIA CODE"
      if self.redeem_code
                  # authentication code for redeem_code
        redeem_obj = self.redeem
                  # set flag for approved/denied - true/false
        if self.redeem_code == redeem_obj.redeem_code
          flag = true
        else
          flag = false
          puts "CUSTOMER REDEEM CODE INCORRECT"
        end
      elsif self.server_code
                  # authenticate for server_code
        codes = self.provider.server_codes
                  # set flag for approval/denied - true/false
        if codes.include? self.server_code
          flag = true
          add_server
        else
          flag = false
          puts "MERCHANT REDEEM CODE INCORRECT"
        end
      else
                  # no code provided - set flag to denied - false
        flag = false
      end
      return flag
    end
    
    def no_gift_id
      self.gift_id.nil?
    end
    
    def add_gift_id
      puts "ADD GIFT ID"
      self.gift_id = self.redeem.gift_id
    end

    def no_redeem_id
      self.redeem_id.nil?
    end

    def add_redeem_id
      puts "ADD REDEEM ID"
      self.redeem_id = self.gift.redeem.id
    end

    def no_provider_id
      self.provider_id.nil?
    end
    
    def add_provider_id
      puts "ADD PROVIDER ID"
      self.provider_id = self.gift.provider_id
    end

    def get_server_id
      if !self.server_id
        puts "SET SERVER ID"
        self.server_id = self.employee.user.id
      end  
    end

    def get_employee_id
      if !self.employee_id
        puts "SET EMPLOYEE ID"
        e = Employee.where(provider_id: self.gift.provider.id, user_id:  sefl.server_id)
        self.employee_id = e.id
      end  
    end  
end
