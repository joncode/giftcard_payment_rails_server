ActiveAdmin.register Provider do
  remove_filter :providers_socials
  remove_filter :socials

  index do
    selectable_column
    id_column
    column :name
    column :address
    column :city
    column :state
    column :zip
    column :region
    column :phone
    column :region
    column :live
    column :payment_plan
    column :payment_event
    column :rate
    column :redemption
    column "Prime Amount" do |p|
      cents_to_currency(p.merchant.try :prime_amount)
    end
    column "Prime Date" do |p|
      p.merchant.try :prime_date
    end
    column "Contract Date" do |p|
      p.merchant.try :contract_date
    end
  end

  csv do
    column :name
    column :address
    column :city
    column :state
    column :zip
    column :region
    column :phone
    column :region
    column :live
    column :payment_plan
    column :payment_event
    column :rate
    column :redemption
    column "Prime Amount" do |p|
      cents_to_currency(p.merchant.try :prime_amount)
    end
    column "Prime Date" do |p|
      p.merchant.try :prime_date
    end
    column "Contract Date" do |p|
      p.merchant.try :contract_date
    end
  end

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end
end
