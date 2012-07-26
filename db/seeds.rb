  
  
# database issues    

# 2 association between menu_string and menu is off because .menu in menu_strings breaks due to confusion with association
# 1 has and belongs to many association from items and menu are off

# 4 the json string has row numbers for iphone when it should just be a menu key with an array of item hashes
######################                USERS               ######################

User.delete_all
User.create([
  { email: 'test@test.com', admin: true, password: 'testtest', password_confirmation: 'testtest', first_name: 'Larry', last_name: 'Page' , city: 'New York', state: 'NY', zip: "11238", phone: '1-646-493-4870', address: '1 Google Drive', credit_number: '4444444444444444'},
  { email: 'jb@jb.com', admin: true, password: 'jessjess', password_confirmation: 'jessjess', first_name: 'Jessica', last_name: 'Balzock' , city: 'New York', state: 'NY', zip: "11238", phone: '345-345-3456', address: '1 Google Drive', credit_number: '4444444444444444'},
  {email: 'gj@gj.com', admin: true, password: 'johnjohn', password_confirmation: 'johnjohn', first_name: 'Greg', last_name: 'Johns' , city: 'New York', state: 'NY', zip: "11238", phone: '4564564567', address: '1 Google Drive', credit_number: '4444444444444444'},
  {email: 'fl@fl.com', admin: true, password: 'fredfred', password_confirmation: 'fredfred', first_name: 'Fredrick', last_name: 'Longfellow' , city: 'New York', state: 'NY', zip: "11238", phone: '+1(567)567-5678', address: '1 Google Drive', credit_number: '4444444444444444'},
  {email: 'jp@jp.com', admin: true, password: 'janejane', password_confirmation: 'janejane', first_name: 'Fredrick', last_name: 'Longfellow' , city: 'New York', state: 'NY', zip: "11238", phone: '6786786789', address: '1 Google Drive', credit_number: '4444444444444444'}
])

# put user_ids in Provider
user = User.all
u_id  = user.map { |u| u.id }

######################                PROVIDERS                ######################

Provider.delete_all
Provider.create([
  { name: "Double Down Saloon" , description: "SHUT UP and DRINK", address: "4640 Paradise Rd", city: "Las Vegas", state: "NV", zip: "89169", user_id: u_id[0] },
  { name: "Hard Rock Hotel & Casino" , description: "Get a Room", address: "4455 Paradise Road", city: "Las Vegas", state: "NV", zip: "89169", user_id: u_id[1] },
  { name: "Hard Rock Hotel & Casino" , description: "Get a Room", address: "207 5th Avenue", city: "San Diego", state: "CA", zip: "92101", user_id: u_id[1] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "825 3rd Avenue", city: "New York", state: "NY", zip: "10022", user_id: u_id[2] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "475 West Broadway", city: "New York", state: "NY", zip: "10012", user_id: u_id[2] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "675 Hudson Street", city: "New York", state: "NY", zip: "10014", user_id: u_id[2] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "373 Park Avenue South", city: "New York", state: "NY", zip: "10016", user_id: u_id[2] },
  { name: "Wynn" , description: "Where the Players Play", address: "3131 Las Vegas Blvd. South", city: "Las Vegas", state: "NV", zip: "89109", user_id: u_id[3] },
  { name: "Encore" , description: "Upscale Casino", address: "3131 Las Vegas Boulevard South", city: "Las Vegas", state: "NV", zip: "89109", user_id: u_id[3] },
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "3935 South Durango Drive ", city: "Las Vegas", state: "NV", zip: "89147", user_id: u_id[4] }, 
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "4825 West Flamingo Road # 3", city: "Las Vegas", state: "NV", zip: "89103", user_id: u_id[4] },  
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "1661 East Sunset Road", city: "Las Vegas", state: "NV", zip: "89119", user_id: u_id[4] },  
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "739 South Rainbow Boulevard", city: "Las Vegas", state: "NV", zip: "89145", user_id: u_id[4] }     
])


######################                ITEMS                ######################

# Item db
# "item_name"
# "detail"
# "category" integer
# BEVERAGE_CATEGORIES = ['special'0, 'beer'1, 'wine'2, 'cocktail'3, 'shot'4]

Item.delete_all
Item.create([
  { item_name: "Corona", detail: "Mexican beer", category: 1},
  { item_name: "Budwesier", detail: "American beer", category: 1},
  { item_name: "Fat Tire", detail: "Colorado beer", category: 1},
  { item_name: "Heineken", detail: "Belgian beer", category: 1},
  { item_name: "Stella Artois", detail: "Belgian beer", category: 1},
  { item_name: "Johnny Walker Black", detail: "whiskey", category: 4},
  { item_name: "Johnny Walker Blue",  detail: "whiskey", category: 4},
  { item_name: "Patron", detail: "tequila", category: 4},
  { item_name: "Louis Tre", detail: "tequila", category: 4},
  { item_name: "Jack Daniels",  detail: "whiskey", category: 4},
  { item_name: "Racecar",  detail: "Vodka Redbull", category: 3},
  { item_name: "Painkiller",  detail: "vodka, gin, vermouth, splash of lime", category: 3},
  { item_name: "Martini",  detail: "gin with olives", category: 3},
  { item_name: "Hurricane",  detail: "vodka & fruit juice", category: 3},
  { item_name: "Irish Car Bomb",  detail: "shot of Baileys in a Guiness", category: 3},
  { item_name: "Helpful Dog",  detail: "Merlot", category: 2},
  { item_name: "Saucy Jack",  detail: "Cabernet Sauvignon", category: 2},
  { item_name: "Copolla",  detail: "Cabernet Sauvignon", category: 2},
  { item_name: "Rothschild",  detail: "Pinot Noir", category: 2},
  { item_name: "Fireman's Special",  detail: "Bud with Tabasco", category: 0}
])


######################                MENUS                ######################
# this does not work because menu is only an ITEM WRAPPER

providers = Provider.all
p_id  = providers.map { |p| p.id }
item = Item.all
i_id  = item.map { |i| i.id }

# "provider_id"
# "item_id"
# "price"
# "position"
menu_array = []
# for each provider_id run this loop
p_id.each do |prov_id|
  # for each item_id run this command
  i_id.each do |item_id|
    # make a hash 
      menu_hash = { provider_id: prov_id, item_id: item_id, price: "10"}
    # add hash to the menu_array
      menu_array << menu_hash
  end
end

Menu.delete_all
Menu.create(menu_array)



######################                MENU_STRINGS                ######################
# "version"
# "provider_id"
# "menu_id" 
# "full_address"
# "data"
MenuString.delete_all
p_id.each do |provider|
  menu = Menu.find_all_by_provider_id(provider)
  menu_string = MenuString.new
  menu_string.provider_id = provider
  menu_string.version = 1
  provider_obj = Provider.find(provider)
  menu_string.full_address = "#{provider_obj.address},  #{provider_obj.city}, #{provider_obj.state}"
  # make an array of hashes of the items
  full_menu_string = { full_address: menu_string.full_address, 
    location_name: menu_string.provider.name }
  num = 1
  menu.each do |m_item|
    item = Item.find(m_item.item_id)
    m_item_hash = { item_id: m_item.item_id,
       item_name: item.item_name, 
       category: item.category, 
       detail: item.detail, 
       price: m_item.price}
    full_menu_string[num] = m_item_hash
    num += 1
  end
  # string_for_json = {} 
  # string_for_json[provider] = full_menu_string 
  string_for_json = Hash[provider, full_menu_string]
  menu_string.data = string_for_json.to_json
  menu_string.save!
end
  
  
  
# database issues    

# 2 association between menu_string and menu is off because .menu in menu_strings breaks due to confusion with association
# 1 has and belongs to many association from items and menu are off

# 4 the json string has row numbers for iphone when it should just be a menu key with an array of item hashes

