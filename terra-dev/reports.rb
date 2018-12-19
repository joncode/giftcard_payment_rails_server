# This file contains reports (surprise surprise)

# Many of them written for one-off queries requested by accounting (craig) or legal (roger)
# or to report monthly/yearly sales numbers for "bizteam" (sales).


# -------------


# Merchant report sorted by created_at, including last_purchased and last_redeemed gift dates
def merchants
  # cols: [:created_at, :live_at, :last_gift_purchased_at, :last_gift_redeemed_at, :live?, :paused?, :id, :name]
  Merchant.where(active: true).order(created_at: :desc).map{ |m|
    "#{m.created_at}\t#{m.live_at ? m.live_at : "n/a"}\t" +
    "#{m.gifts.order(created_at: :desc).first.created_at rescue "-"}\t" +
    "#{m.gifts.where.not(redeemed_at: nil).order(redeemed_at: :desc).first.redeemed_at rescue "-"}\t" +
    "#{m.live ? "live" : "-"}\t" +
    "#{m.paused ? "paused" : "-"}\t" +
    "#{m.id}\t" +
    "#{m.name}"
  }.insert(0, [:created_at, :live_at, :last_gift_purchased_at,
               :last_gift_redeemed_at, :live?, :paused?, :id, :name].join("\t")
  ).join("\n")
end
#   SELECT  created_at, live_at,
#           (    SELECT  g.created_at
#                    AS  last_gift_purchased_at
#                  FROM  merchants  as m
#             LEFT JOIN  gifts      as g
#                    ON  g.merchant_id = m.id
#              ORDER BY  g.created_at desc
#                 LIMIT  1
#           ),
#           (    SELECT  g.redeemed_at
#                    AS  last_gift_redeemed_at
#                  FROM  merchants  as m
#             LEFT JOIN  gifts      as g
#                    ON  g.merchant_id = m.id
#              ORDER BY  g.redeemed_at desc
#                 LIMIT  1
#           ),
#           live, paused, id, name
#     FROM  merchants
#    WHERE  active = 't'
# ORDER BY  created_at






def live_merchants_golf_vs_nongolf
  golfnow_affiliate_id = Affiliate.find_by_first_name("GolfNow").id
  {
    live_golf_merchants:     Merchant.where(active: true, live: true).where(affiliate_id: golfnow_affiliate_id).count,
    live_nongolf_merchants:  Merchant.where(active: true, live: true).where(affiliate_id: nil).count
  }
end
# live_merchants_golf_vs_nongolf



# Top5 report for golf/non-golf in 2016/2017 as a \t-delimited CSV:
def top5(year, golf)
  sold_year      =  "sold_#{year}".to_sym
  value_year     = "value_#{year}".to_sym
  affiliate_id   = (!golf ? nil : Affiliate.find_by_first_name("GolfNow").id)  # Golf or not
  date_range     = (Date.new(year)...Date.new(year+1))
  merchant_gifts = []

  # Count the number of standard gifts merchants sold within the given year, and sum their values.
  Merchant.where(affiliate_id: affiliate_id).each{ |m|
    gifts = Gift.where(merchant_id: m.id).where(cat: 300)
    data  = { id: m.id,  name: m.name }
    data[sold_year]  = gifts.where(created_at: date_range).count
    data[value_year] = gifts.where(created_at: date_range).inject(0) {|sum, gift| sum + gift.value.to_f}
    merchant_gifts << data
  }

  # Pick out the Top 5
  results = merchant_gifts.sort_by{|m_gift| m_gift[sold_year]}.reverse[0...5]
  # Construct a tab-delimited CSV
  csv     = results.collect{|result| "#{result[:id]}\t#{result[:name]}\t#{result[sold_year]}\t$#{'%.2f' % result[value_year]}" }
  # Add column headers
  csv.insert(0, merchant_gifts.first.keys.collect{|key| key.to_s}.join("\t")).join("\n")

  csv
end





# Merchants who sold >[1, 10, 50, 100] gifts between `date` and now.
def purchased_gift_counts(begin_date, end_date=Time.new, counts=[1,10,50,100,500])
  require 'pp'

  # Convert date->time
  begin_date = begin_date.to_time  if begin_date.respond_to? :to_time
  end_date   =   end_date.to_time  if end_date.respond_to?   :to_time
  date_range = (begin_date...end_date)

  gift_counts = Hash.new(0)

  Merchant.all.each do |merchant|
    gift_count = merchant.gifts.where(created_at: date_range).count
    counts.each do |group_count|
      gift_counts[group_count] += 1  if gift_count >= group_count 
    end
  end

  printf "Report name: Purchased gift counts for all merchants\n"
  printf "Groupings:   #{counts.inspect}\n"
  printf "Date begin:  #{begin_date} (inclusive)\n"
  printf "Date end:    #{end_date  } (not inclusive)\n"
  printf "CSV: (tab-delimited)\n"
  printf "gift count\tmerchant count\n"
  gift_counts.each{|k,v| printf "#{k}\t#{v}\n" }
  printf "\n"

  gift_counts
end

# purchased_gift_counts Date.new(2016,11,24), Date.new(2016,12,23)
# purchased_gift_counts Date.new(2017,11,25), Date.new(2017,12,23)
# purchased_gift_counts Date.new(2017,11,24), Date.new(2017,11,25)
# purchased_gift_counts Date.new(2017,12,22), Date.new(2017,12,23)





# Thes should already be defined as `REDEMPTION_HSH` and `GIFT_CAT`
# I've included them here for clarity, and renamed them to avoid reassignment errors
REDEMPTION_TYPES = { 1 => "V1" , 2 => "V2", 3 => "Omnivore", 4 => 'Paper', 5 => 'Zapper', 6 => 'Admin?', 7 => 'Clover', 8 => 'Epson' }
GIFT_CATS = {100 => "Admin",    101 => "AdmRegift",      107 => "AdmBoom",      150 => "AdmCamp",   151 => "AdmCampRegift",   157 => "AdmCampBoom",
             200 => "Merchant", 201 => "MerchantRegift", 207 => "MerchantBoom", 250 => "MerchCamp", 251 => "MerchCampRegift", 257 => "MerchCampBoom",
             300 => "Standard", 301 => "StndRegift",     307 => "StndBoom"}


# Generate a csv detailing the last `number` of gifts
def csv_of_last_gifts(number:500)

  Gift.where(active: true).order(created_at: :desc).limit(number).map{ |gift|
    details = []
    details << gift.id
    details << gift.created_at
    details << gift.provider_name
    details << gift.cat
    details << GIFT_CATS[gift.cat.to_i]
    details << gift.value

    # Parse the cart for vouchers (count and percentage of total value)
    value_vouchers = []
    value_total    = 0

    cart = JSON.parse(gift.shoppingCart)
    cart.each do |item|
      value_total += item["price"].to_i

      unless item["item_name"].match(/(gift|card|voucher)/i).nil?
        value_vouchers << item["price"].to_i
      end
    end

    # voucher, total count
    details << value_vouchers.count
    details << cart.size
    # xx.xx% of value made up of vouchers
    if value_total == 0
      details << "-"
    else
      details << ("%2.f" % (100 * (value_vouchers.sum.to_f / value_total))) + "%"
    end

    details.join("\t")
  }.insert(0,
    [:id, :created_at, :provider_name, :category, :friendly_category, :value, :voucher_count, :item_count, :voucher_value_percentage].join("\t")
  ).join("\n")
end

# printf csv_of_last_gifts(number: 1000)




# # Generate a csv detailing the last `number` of redemptions
# def csv_of_last_redemptions(number:500)
#   Redemption.where(active: true).order(created_at: :desc).limit(number).map{ |redemption|
#     details = []
#     details << redemption.id
#     details << redemption.created_at
#     details << redemption.merchant.name rescue "-"
#     details << redemption.type_of
#     details << redemption.r_sys
#     details.join("\t")
#   }.insert(0,
#     [:id, :created_at, :provider_name, :category, :friendly_category, :value].join("\t")
#   ).join("\n")
# end





def sales_side_by_side(range1, range2)

  def _golf(gifts)
    golf_affiliate_id = Affiliate.find_by_first_name("GolfNow").id

    gifts.reject do |gift|
      gift.merchant.affiliate_id == golf_affiliate_id
    end
  end

  def _non_golf(gifts)
    ##! This may cause issues later if we have more Affiliates
    gifts.reject do |gift|
      gift.merchant.affiliate_id == nil
    end
  end


  #TODO: generate headers list from a ranges splat
  csv = {
    headers: ["First date range",  "Golf Gifts", "Golf CAD", "Golf USD", "Golf Subtotal", "Non-golf Gifts", "Non-golf CAD", "Non-golf USD",  "Non-golf Subtotal", "Total CAD", "Total USD", "Total Sales",
              nil,
              "Second date range", "Golf Gifts", "Golf CAD", "Golf USD", "Golf Subtotal", "Non-golf Gifts", "Non-golf CAD", "Non-golf USD",  "Non-golf Subtotal", "Total CAD", "Total USD", "Total Sales"],
    rows:    []
  }



  [range1, range2].each.with_index do |range, index|
    puts "Working on range: #{range.inspect}"
    row_id = 0
    range.each do |date|
      gifts = Gift.where(created_at: date...date+1.day).where(cat: 300)
      gifts_golf     = _golf(gifts)
      gifts_non_golf = _non_golf(gifts)

      csv[:rows][row_id] ||= []
      offset = index * (csv[:headers].count/2 + 1)

      # Alias as `row` to save lookups (and typing)
      row = csv[:rows][row_id]

      # First date range
      row[offset + 0] = date.to_s

      # Golf Gifts
      row[offset + 1] = gifts_golf.count
      # Golf CAD
      row[offset + 2] = _golf(gifts.where(ccy: "CAD")).collect{|gift| gift.original_value}.sum / 100.0
      # Golf USD
      row[offset + 3] = _golf(gifts.where(ccy: "USD")).collect{|gift| gift.original_value}.sum / 100.0
      # Golf Subtotal
      row[offset + 4] = gifts_golf.collect{|gift| gift.original_value}.sum / 100.0

      # Non-golf Gifts
      row[offset + 5] = gifts_non_golf.count
      # Non-golf CAD
      row[offset + 6] = _non_golf(gifts.where(ccy: "CAD")).collect{|gift| gift.original_value}.sum / 100.0
      # Non-golf USD
      row[offset + 7] = _non_golf(gifts.where(ccy: "USD")).collect{|gift| gift.original_value}.sum / 100.0
      # Non-golf Subtotal
      row[offset + 8] = gifts_non_golf.collect{|gift| gift.original_value}.sum / 100.0

      # Total CAD
      row[offset + 9] = row[offset + 2] + row[offset + 6]
      # Total USD
      row[offset + 10] = row[offset + 3] + row[offset + 7]
      # Total Sales"
      row[offset + 11] = row[offset + 4] + row[offset + 8]

      puts row.inspect

      row_id += 1
    end
  end

  output = []
  output << csv[:headers].join(',')
  csv[:rows].each do |row|
    output << row.join(',')
  end

  output.join("\n")
end


# access_code_csv( Merchant.where("name ILIKE '%craig%'") )





# day    = Date.new(2018,6,18)  # Day after father's day
# days   = [day-8.days, day]
#
# day    = Date.new(2018,1,1)
# days   = [day, day+1.year]
#
# range2 = days.first..days.last
# range1 = (days.first-1.year)...(days.last-1.year)
#
#
# sales_side_by_side(range1, range2)









def access_code_csv(merchants)
  merchants = [merchants]  if merchants.is_a? Merchant

  csv = []
  csv << %i[id name admin? manager? employee? code moderated? created_by].join(',')


  merchants.each do |merchant|
    merchant.access_codes.where(active: true).each do |grant|
      row = []
      row << merchant.id
      row << merchant.name.gsub(/,/, ' ')

      role = grant.role.role
      row << (role == 'admin'    ? 'x' : '')
      row << (role == 'manager'  ? 'x' : '')
      row << (role == 'employee' ? 'x' : '')

      row << grant.code
      row << (grant.approval_required ? 'x' : '')

      grant.created_by.nil? ?
          row << '' :
          row << (User.find(grant.created_by).name.gsub(/,/, ' ')  rescue '(lookup error)')

      csv << row.join(',')
    end
  end

  csv.join("\n")
end


# printf access_code_csv( Merchant.where("name ILIKE '%dairy queen%'") )





# report of all golf C2C gift cards that have redemptions initiated that never were marked as used by golf course
# or:  cat 300+ golf gifts with expired redemptions
def golf_gifts_with_expired_redemptions
  # This does not work because there is no way to disable default scopes in ActiveRecord subqueries:
  #    Gift.golf_gifts.joins(:redemptions).where("redemptions.status" => 'expired')

  # (Disabled because `Gift.golf_gifts` isn't on production yet)
  # So let's write the join out manually instead:
  # gifts = Gift.golf_gifts           \
  #             .where('cat >= 300')  \
  #             .joins('LEFT JOIN redemptions ON redemptions.gift_id = gifts.id')  \
  #             .where('redemptions.status' => 'expired')

  gifts = Gift.where('cat >= 300')  \
              .joins(:merchant)     \
              .where(merchants: {affiliate_id: Affiliate.find_by_first_name("GolfNow").id})  \
              .joins('LEFT JOIN redemptions ON redemptions.gift_id = gifts.id')  \
              .where('redemptions.status' => 'expired')  \
              .order(created_at: :desc)

  header = %i[id gift_id purchase_date gift_value gift_balance redemption_id redemption_date redemption_status redemption_amount]
  header = header.map{|h| h.to_s.titleize}.join(',')

  csv = []
  csv << [ header ]

  gifts.each.with_index do |gift, gift_index|
    Redemption.where(gift_id: gift.id).order(created_at: :desc).each.with_index do |redemption, redemption_index|
      row = []
      row << "#{gift_index+1}-#{redemption_index+1}"
      row << gift.hex_id
      row << gift.created_at.to_s
      row << number_to_currency(gift.original_value / 100.0)
      row << number_to_currency(gift.balance / 100.0)
      row << redemption.hex_id
      row << redemption.created_at.to_s
      row << redemption.status
      row << number_to_currency(redemption.amount / 100.0)

      csv << row.join(',')
    end
  end

  csv.join("\n")
end

# golf_gifts_with_expired_redemptions





def merchant_contact_csv(city:nil)
  raise ArgumentError, "Missing city!"  if city.nil?

  def _format_address(address:nil, address2:nil, city:nil, state:nil, zip:nil)
      address2 = [ city,       state ].reject{|str| str.nil? || str.empty?}.join(', ')
      address2 = [ address2,     zip ].reject{|str| str.nil? || str.empty?}.join('  ')
      address  = [ address, address2 ].reject{|str| str.nil? || str.empty?}.join("\n")
      return address
  end

  csv = []
  header = %i[merchant_name link address city zip phone email signup_name signup_email]
  header = header.map{|h| h.to_s.titleize}.join(',')
  csv << [header]

  Merchant.where("city_name ILIKE '%#{city}%'").each do |merchant|
    row = []
    row << (merchant.name.gsub(/,/, '')  rescue nil)
    row << "https://admin.itson.me/merchants/#{merchant.hex_id}"
    # row << _format_address(address:merchant.address, address2:merchant.address2, city:merchant.city, state:merchant.state, zip:merchant.zip)
    row << (merchant.address.gsub(/,/, '')  rescue nil)
    row << merchant.city
    row << merchant.zip
    row << merchant.phone
    row << merchant.email
    row << (merchant.signup_name.gsub(/,/, '')  rescue nil)
    row << merchant.signup_email

    csv << row.join(',')
  end

  csv.join("\n")
end

# printf merchant_contact_csv(city: "vegas")








# Simple array-to-csv method
class Array

  def to_csv(delimiter: ",")
    # Assumption: the first row is the headers
    csv = ""
    self.each.with_index do |row, index|
      if index == 0
        csv += row.map(&:to_s).map(&:titleize).join(delimiter)
        next
      end

      csv += "\n"
      csv += row.join(delimiter)
    end
    csv
  end

end



# ------------- ------------- -------------

# This iterator calls the given block (report) once per month for the given year,
# and aggregates the returned data into a table. This means stripping the header
# and adding a 'month' column.
#
# Caveat: This will remove the columns [:start_date, :end_date] so make sure all
#         reports use these names. I chose this over passing an `include_dates:`
#         param so the iterator will work with all reports.


class Fixnum

  def monthly_report
    require 'date'

    year = self
    months = %w[January February March April May June July August September October November December]
    table = []

    1.upto(12) do |month|
      start     = Date.new(year, month)
      terminus  = start + 1.month
      daterange = (start...terminus)
      report    = yield(daterange)

      # Pull out the header
      header = report.first

      # Find the indexes of these columns and remove them from the report data
      remove_cols = []
      remove_cols << header.index(:start_date)
      remove_cols << header.index(:start_date.to_s.titleize)
      remove_cols << header.index(:end_date)
      remove_cols << header.index(:end_date.to_s.titleize)
      remove_cols = remove_cols.compact.sort.reverse  # strip nils, and put the highest indexes first

      report.each do |row|
        remove_cols.each do |col_index|
          row.delete_at(col_index)
        end
      end

      # Add the month column and data
      report.first.prepend("Month")
      report.last.prepend("#{months[month-1]} #{year}")

      # Only add the header once
      table << report.first  if month == 1
      table << report.last
    end

    table
  end

end



# ------------- ------------- -------------


def total_gifts(daterange)
  data = Gift.where(created_at: daterange).count

  table = []
  table << [:start_date, :end_date, :total_gifts]
  table << [daterange.min, daterange.max, data]
  table
end
# printf 2018.monthly_report{|month| total_gifts(month) }.to_csv(delimiter: "\t"); nil


def total_gifts_by_cat(daterange)
  header = [:start_date, :end_date]
  data   = [daterange.min, daterange.max]

  GIFT_CATS.each do |cat, str|
    header.push "#{cat} (#{str})"
    data.push Gift.where(created_at: daterange, cat: cat).count
  end

  [header, data]
end
# printf 2018.monthly_report{|month| total_gifts_by_cat(month) }.to_csv(delimiter: "\t"); nil


def total_purchased_revenue(daterange)
  header = [:start_date, :end_date, :gift_revenue]
  data   = [daterange.min, daterange.max]

  # Tally up the original purchase amounts, convert cents->dollars, and display with 2 fixed decimal places
  data.push sprintf("$%.2f", Gift.where(created_at: daterange).map(&:purchase_cents).inject(0, :+) / 100.0)

  [header, data]
end
# printf 2018.monthly_report{|month| total_purchased_revenue(month) }.to_csv(delimiter: "\t"); nil


def total_purchased_profit(daterange)
  header = [:start_date, :end_date, :gift_profit]
  data   = [daterange.min, daterange.max]

  # Construt a Merchant.rate hash to avoid needless DB churn
  merchant_ids = Gift.where(created_at: daterange).pluck(:merchant_id).uniq
  merchant_rates = {}
  Merchant.find(merchant_ids).each do |merchant|
    # Convert from merchant profitshare percentage (e.g. 95.0) to IOM profit decimal (e.g. 0.05)
    merchant_rates[merchant.id] = (1 - (merchant.rate/100.0)).to_f   # Specifically in this order to reduce floating point errors
  end

  profit = 0
  Gift.where(created_at: daterange).each do |gift|
    profit += gift.purchase_cents * merchant_rates[gift.merchant_id]
  end

  # Tally up the original purchase amounts, convert cents->dollars, and display with 2 fixed decimal places
  data.push sprintf("$%.2f", profit/100.0)

  [header, data]
end
# printf 2018.monthly_report{|month| total_purchased_profit(month) }.to_csv(delimiter: "\t"); nil




def total_golf_nongolf_purchases(daterange)
  header = [:start_date, :end_date, :golf_purchases, :non_golf_purchases, :total_purchases]
  data   = [daterange.min, daterange.max]

  golfnow_affiliate_id = Affiliate.find_by_first_name("GolfNow").id
  golfnow_merchant_ids = Merchant.where(affiliate_id: golfnow_affiliate_id).pluck(:id)

  golf    = 0
  nongolf = 0

  Gift.where(created_at: daterange).where(cat: 300).each do |gift|
    if golfnow_merchant_ids.include?(gift.merchant_id)
      golf += 1
    else
      nongolf += 1
    end
  end

  data.push(golf)
  data.push(nongolf)
  data.push(golf+nongolf)

  [header, data]
end
# printf 2018.monthly_report{|month| total_golf_nongolf_purchases(month) }.to_csv(delimiter: "\t"); nil




def total_gift_purchases_by_client_type(daterange)
  header = [:start_date, :end_date]
  data   = [daterange.min, daterange.max]

  types = {
    android:       0,
    ios:           0,
    menu_facebook: 0,
    menu_widget:   0,
    unknown:       0,  # Gifts without a client_id set
  }

  # Only tally up consumer gifts (cat 3xx)
  Gift.where(created_at: daterange).where("cat >= 300").each do |gift|
    type = (gift.client.platform.to_sym  rescue :unknown)
    types[type] += 1
  end

  # Append the data (using sorted keys since Hash order isn't guaranteed)
  types.keys.sort.each do |type|
    header.push(type)
    data.push(types[type])
  end

  [header, data]
end
# printf 2018.monthly_report{|month| total_gift_purchases_by_client_type(month) }.to_csv(delimiter: "\t"); nil




def total_mobile_nonmobile_purchases(daterange)
  header = [:start_date, :end_date, :mobile_purchases, :non_mobile_purchases, :total_purchases]
  data   = [daterange.min, daterange.max]

  mobile    = 0
  nonmobile = 0

  Gift.where(created_at: daterange).each do |gift|
    if gift.origin.match /(i(phone|pad|pod)|android|phone)/i
      mobile += 1
    else
      nonmobile += 1
    end
  end

  data.push(mobile)
  data.push(nonmobile)
  data.push(mobile+nonmobile)

  [header, data]
end
# printf 2018.monthly_report{|month| total_mobile_nonmobile_purchases(month) }.to_csv(delimiter: "\t"); nil



def gift_redemption_spread(daterange)
  header      = [:start_date, :end_date]
  data        = [daterange.min, daterange.max]
  percentages = Array.new(11, 0)  # Counter array, 10..0

  10.downto(0) do |percentage|
    header.push("#{percentage*10}% redeemed")
  end

  Gift.where(created_at: daterange).each do |gift|
    next if gift.brand_card?
    next if gift.original_value == 0  # MT gifts have $0 retail values, and should not be included in this report anyway

    # $90/$100 is 10% redeemed
    # 90/100     = 0.9
    # 0.9 * 10   = 9
    # percentages[9] -> 10% redeemed
    decimal = BigDecimal.new(gift.balance) / gift.original_value.to_f  # because floating point errors
    percent = (decimal*10).to_i

    # 1% remaining -> 100% redeemed?  No no no.  Bump it back to 90%.
    percent += 1  if percent == 0  && gift.balance != 0
    # likewise for 99% remaining -> 0% redeemed
    percent -= 1  if percent == 10 && gift.balance != gift.original_value

    # increment counter
    percentages[ percent.to_i ] += 1
  end

  data.push(*percentages)

  [header, data]
end
# printf 2018.monthly_report{|month| gift_redemption_spread(month) }.to_csv(delimiter: "\t").gsub(/%/, '%%'); nil




def total_redemptions(daterange)
  header = [:start_date, :end_date, :total_redemptions]
  data   = [daterange.min, daterange.max]

  data.push Redemption.where(created_at: daterange).count

  [header, data]
end
# printf 2018.monthly_report{|month| total_redemptions(month) }.to_csv(delimiter: "\t"); nil





def total_redemptions_by_type(daterange)
  header = [:start_date, :end_date]
  data   = [daterange.min, daterange.max]
  
  # counters
  types = Hash.new(0)
  Redemption.where(created_at: daterange).pluck(:r_sys).each do |r_sys|
    types[r_sys] += 1
  end

  REDEMPTION_TYPES.each do |id, string|
    header.push("#{string} (#{id})")
    data.push(types[id])
  end

  [header, data]
end
# printf 2018.monthly_report{|month| total_redemptions_by_type(month) }.to_csv(delimiter: "\t"); nil



def total_live_nonlive_merchants(daterange)
  header = [:start_date, :end_date, :live_merchants, :non_live_merchants, :total_merchants]
  data   = [daterange.min, daterange.max]

  merchants = Merchant.where("created_at < '#{daterange.max}'")
  total = merchants.count
  live  = merchants.where(active: true, live: true).where("live_at < '#{daterange.max}'").count

  data.push(live)  # set live before the report terminus
  data.push(total-live)
  data.push(total)

  [header, data]
end
# printf 2018.monthly_report{|month| total_live_nonlive_merchants(month) }.to_csv(delimiter: "\t"); nil




def total_new_merchants(daterange)
  header = [:start_date, :end_date, :new_merchants]
  data   = [daterange.min, daterange.max]

  data.push( Merchant.where(created_at: daterange).count )

  [header, data]
end
# printf 2018.monthly_report{|month| total_new_merchants(month) }.to_csv(delimiter: "\t"); nil



# Merchants that sold a giftcard within the previous month
def total_active_merchants(daterange)
  header = [:start_date, :end_date, :active_merchants]
  data   = [daterange.min, daterange.max]

  active_daterange = (daterange.min - 1.month)...(daterange.max)
  active_merchants = Gift.where(created_at: active_daterange).pluck(:merchant_id).compact.uniq.count

  data.push(active_merchants)

  [header, data]
end
# printf 2018.monthly_report{|month| total_active_merchants(month) }.to_csv(delimiter: "\t"); nil



def total_golf_nongolf_merchants(daterange)
  header = [:start_date, :end_date, :golf_merchants, :non_golf_merchants, :total_merchants]
  data   = [daterange.min, daterange.max]

  golfnow_affiliate_id = Affiliate.find_by_first_name("GolfNow").id

  # Active merchants created and set live prior to the report terminus
  merchants = Merchant.where("created_at < '#{daterange.max}'").where(active: true, live: true).where("live_at < '#{daterange.max}'")


  golf     = merchants.where(affiliate_id: golfnow_affiliate_id).count
  nongolf  = merchants.count - golf

  data.push(golf)
  data.push(nongolf)
  data.push(golf+nongolf)

  [header, data]
end
# printf 2018.monthly_report{|month| total_golf_nongolf_merchants(month) }.to_csv(delimiter: "\t"); nil



def total_live_mta_nonmta_merchants(daterange)
  header = [:start_date, :end_date, :live_mta_merchants, :live_non_mta_merchants, :total_live_merchants]
  data   = [daterange.min, daterange.max]

  merchants = Merchant.where("created_at < '#{daterange.max}'").where(active: true, live: true).where("live_at < '#{daterange.max}'")

  nonmta = 0
  merchants.each do |merchant|
    nonmta += 1  if merchant.access_grants.empty?
  end

  mta = merchants.count - nonmta

  data.push(mta)
  data.push(nonmta)
  data.push(mta+nonmta)

  [header, data]
end
# printf 2018.monthly_report{|month| total_live_mta_nonmta_merchants(month) }.to_csv(delimiter: "\t"); nil




def total_live_merchants_by_redemption_system(daterange)
  header = [:start_date, :end_date]
  data   = [daterange.min, daterange.max]
  
  # counters
  types = Hash.new(0)

  # 151 character line.  Too tired to make it pretty.
  Merchant.where("created_at < '#{daterange.max}'").where(active: true, live: true).where("live_at < '#{daterange.max}'").pluck(:r_sys).each do |r_sys|
    types[r_sys] += 1
  end

  REDEMPTION_TYPES.each do |id, string|
    header.push("#{string} (#{id})")
    data.push(types[id])
  end

  [header, data]
end
# printf 2018.monthly_report{|month| total_live_merchants_by_redemption_system(month) }.to_csv(delimiter: "\t"); nil



# Dawn of The Final Day
# These reports remain:

# Gift Reporting (in 2018, by Month)
#   * Total Count
#   * Total Count in each Category
#   * Total Purchased Revenue
#   * Total Purchased Profit
#   * Total Purchase Count (Golf vs Non Golf)
#   * Total Widget vs App vs WWW
#   * Total Mobile Device vs Non-Mobile Device (if possible)
#   - Claimed vs Unclaimed
#   * Redeemed (with percentage redeemed and/or amount remaining) vs Non-Redeemed

# Redemption Reporting (in 2018, by Month)
#   * Total Redeemed
#   * Total Redeemed by Redemption Type

# Merchant Reporting (in 2018, by Month)
#   * Total Count (live, nonlive)
#   * Total New
#   * Total Active (had at least 1 gift purchase in the month)
#   * Golf vs Non Golf
#   * On MTA vs Not

# Also:
#   * side by side 2017/2018
#   * Merchants on each redemption type
