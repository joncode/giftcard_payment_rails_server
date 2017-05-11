require 'gibberish'

class Bank < ActiveRecord::Base
    include Formatters

#   -------------

    before_validation   :strip_whitespace_and_fix_case

#   -------------

    validates :aba, length: { within: 6..10, if: :aba_changed? }, confirmation: true
    validates :aba_confirmation, presence: true, if: :aba_changed?
    validates :account_number, length: { within: 6..14, if: :account_number_changed? }, confirmation: true
    validates :account_number_confirmation, presence: true, if: :account_number_changed?
    validates_length_of :state , :is => 2
    validates_length_of :zip, :within => 5..10
    validates_presence_of :name, :address, :city, :account_name, :acct_type, :aba, :account_number

#   -------------

    before_save  :encrypt_account_info
    after_create :update_progress_int

#   -------------

    has_many :merchants
    has_many :affiliates
    has_many :payments

    belongs_to :owner, polymorphic: true


    def acct_type=(account_type)
        if account_type == "checking"
            super(0)
        elsif account_type == "savings"
            super(1)
        else
            super
        end
    end

    def acct_type
        case super
        when 0
            "checking"
        when 1
            "savings"
        else
            nil
        end
    end

    def admt_serialize
        hsh = self.serializable_hash only: [:name, :acct_type, :account_name]
        hsh["aba"]            = self.aba
        hsh["account_number"] = self.account_number
        hsh["address"]        = html_complete_address
        hsh
    end

    def self.decrypt data
        if data.present?
            cipher = Gibberish::RSA.new(GIBBERISH_PRIVATE_KEY)
            cipher.decrypt(data)
        else
            ""
        end
    end

#   -------------

    def display_aba current_user=nil
        if current_user == :acct
            if Rails.env.production?
                Bank.decrypt self.aba
            else
                '11000-000'
            end
        else
            self.public_aba
        end
    end

    def display_account_number current_user=nil
        if current_user == :acct
            if Rails.env.production?
                Bank.decrypt self.account_number
            else
                '000123456789'
            end
        else
            self.public_account_number
        end
    end

    def encrypt_account_info
        cipher = Gibberish::RSA.new(GIBBERISH_PUBLIC_KEY)
        if account_number_not_encrypted
            self.public_account_number = ("X" * (self.account_number.length - 4)) + self.account_number.last(4)
            self.account_number        = cipher.encrypt(self.account_number)
        end

        if aba_not_encrypted
            self.public_aba            = ("X" * (self.aba.length - 4)) + self.aba.last(4)
            self.aba                   = cipher.encrypt(self.aba)
        end
    end

private

    def account_number_not_encrypted
        self.account_number.present? && self.account_number.length < 15
    end

    def aba_not_encrypted
        self.aba.present? && self.aba.length < 15
    end

    def update_progress_int
        progress = self.merchant.progress
        progress.update_attribute(:bank, 1)
    end

    def strip_whitespace_and_fix_case
        self.name         = self.name.strip if self.name.present?
        self.account_name = self.account_name.strip if self.account_name.present?
        self.city         = self.city.titleize.strip if self.city.present?
        self.zip          = self.zip.strip if self.zip.present?
    end

end
# == Schema Information
#
# Table name: banks
#
#  id                    :integer         not null, primary key
#  merchant_id           :integer
#  aba                   :string(255)
#  account_number        :string(255)
#  name                  :string(255)
#  address               :string(255)
#  city                  :string(50)
#  state                 :string(2)
#  zip                   :string(16)
#  account_name          :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  acct_type             :integer
#  country               :string(255)     default("USA")
#  public_account_number :string(255)
#  public_aba            :string(255)
#

