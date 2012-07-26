######################                USERS               ######################


User.delete_all
User.create([
  {username: 'admin', email: 'test@test.com', admin: true, password: 'testtest', password_confirmation: 'testtest', first_name: 'Larry', last_name: 'Page' , city: 'New York', state: 'NY', zip: 11238, phone: '1-646-493-4870', address: '1 Google Drive', credit_number: '4444444444444444'},
  {username: '', email: 'jb@jb.com', admin: true, password: 'jessjess', password_confirmation: 'jessjess', first_name: 'Jessica', last_name: 'Balzock' , city: 'New York', state: 'NY', zip: 11238, phone: '345-345-3456', address: '1 Google Drive', credit_number: '4444444444444444'},
  {username: '', email: 'gj@gj.com', admin: true, password: 'johnjohn', password_confirmation: 'johnjohn', first_name: 'Greg', last_name: 'Johns' , city: 'New York', state: 'NY', zip: 11238, phone: '4564564567', address: '1 Google Drive', credit_number: '4444444444444444'},
  {username: '', email: 'fl@fl.com', admin: true, password: 'fredfred', password_confirmation: 'fredfred', first_name: 'Fredrick', last_name: 'Longfellow' , city: 'New York', state: 'NY', zip: 11238, phone: '+1(567)567-5678', address: '1 Google Drive', credit_number: '4444444444444444'},
  {username: '', email: 'jp@jp.com', admin: true, password: 'janejane', password_confirmation: 'janejane', first_name: 'Fredrick', last_name: 'Longfellow' , city: 'New York', state: 'NY', zip: 11238, phone: '6786786789', address: '1 Google Drive', credit_number: '4444444444444444'}
])

# put user_ids in Provider
user = User.all
u_id  = user.map { |u| u.id }

######################                PROVIDERS                ######################

Provider.delete_all
Provider.create([
  { name: "Double Down Saloon" , description: "SHUT UP and DRINK", address: "4640 Paradise Rd", city: "Las Vegas", state: "NV", zip: 89169, user_id: u_id[0] },
  { name: "Hard Rock Hotel & Casino" , description: "Get a Room", address: "4455 Paradise Road", city: "Las Vegas", state: "NV", zip: 89169, user_id: u_id[1] },
  { name: "Hard Rock Hotel & Casino" , description: "Get a Room", address: "207 5th Avenue", city: "San Diego", state: "CA", zip: 92101, user_id: u_id[1] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "825 3rd Avenue", city: "New York", state: "NY", zip: 10022, user_id: u_id[2] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "475 West Broadway", city: "New York", state: "NY", zip: 10012, user_id: u_id[2] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "675 Hudson Street", city: "New York", state: "NY", zip: 10014, user_id: u_id[2] },
  { name: "Dos Caminos" , description: "Modern Mexican Food and Tequila Lounge", address: "373 Park Avenue South", city: "New York", state: "NY", zip: 10016, user_id: u_id[2] },
  { name: "Wynn" , description: "Where the Players Play", address: "3131 Las Vegas Blvd. South", city: "Las Vegas", state: "NV", zip: 89109, user_id: u_id[3] },
  { name: "Encore" , description: "Upscale Casino", address: "3131 Las Vegas Boulevard South", city: "Las Vegas", state: "NV", zip: 89109, user_id: u_id[3] },
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "3935 South Durango Drive ", city: "Las Vegas", state: "NV", zip: 89147, user_id: u_id[4] }, 
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "4825 West Flamingo Road # 3", city: "Las Vegas", state: "NV", zip: 89103, user_id: u_id[4] },  
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "1661 East Sunset Road", city: "Las Vegas", state: "NV", zip: 89119, user_id: u_id[4] },  
  { name: "PT's Pub" , description: "Real. Local. Play.", address: "739 South Rainbow Boulevard", city: "Las Vegas", state: "NV", zip: 89145, user_id: u_id[4] }     
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

provider = Provider.all
p_id  = provider.map { |p| p.id }
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
      menu_hash = { provider_id: prov_id, item_id: item_id, price: 10}
    # add hash to the menu_array
      menu_array << menu_hash
  end
end

Menu.delete_all
Menu.create(menu_array)



######################                MENU_STRINGS                ######################
# "version"
# "provider_id"
# "menu_id"                this does not work because menu_id is only an ITEM WRAPPER
# "full_address"
# "menu"
MenuString.delete_all
# iterate thru each provider_id
p_id.each do |provider|
  menu = Menu.find_by_provider_id(provider)
  # make a new MenuString object
  menu_string = MenuString.new
  # take the menu.provider_id and save it into this
  menu_string.provider_id = provider
  # menu_string.menu_id = menu.id   *** does not work
  # get the provider address information and make the full address
  menu_string.full_address = "#{menu.provider.address},  #{menu.provider.city}, #{menu.provider.state}"
  menu_string.version = 1
  # make an array of hashes of the items
  menu_row_hash = {}
  num = 1
  menu.each do |m_item|
    # hash keys
    m_item_hash = { item_id: m_item.item_id, item_name: m_item.item.item_name, category: m_item.item.category, detail: m_item.item.detail, price: m_item.price}
    # item_id
    # item_name
    # category
    # detail
    # price   - this is from the menu.price
  # put the menu.items into an array
    menu_row_hash[num] = m_item_hash
    num += 1
  end
  # take the menu_array and set menu_string.menu equal to it
  menu_string.menu = menu_row_hash
  # create the 


  # save the location_name into the hash system
  location_name = menu_string.provider.name
{"1":
  {"full_address": "131 W 3rd Street, New York City, NY","location_name": "Blue Note Jazz Club",
    "menu": [
    {"item_id":"101","item_name":"Corona","category":"1","detail":"Mexico City, Mexico (bottle)","price":"$5.25"},
    {"item_id":"102","item_name":"Bud Light","category":"1","detail":"St. Louis, Missouri, USA (bottle)","price":"$4.00"},
    {"item_id":"103","item_name":"White Zenfindel","category":"2","detail":"St. Louis, Missouri, USA (glass)","price":"$8.00"}]
},

"2":
  {"full_address":"56 Beaver Street, New York City, NY",
    "location_name":"Delmonico's",
    "1":
      {"item_id":"104","item_name":"Vegas Bomb",
      "category":"4","detail":"peach snops, red bull, crown royal",
      "price":"$7.50"},
    "2":
      {"item_id":"105",
        "item_name":"3",
        "category":"Purple Martini",
        "detail":"special blend",
        "price":"$10.00"},

"3":{"item_id":"106","item_name":"1","category":"Stella Artios","detail":"Leuven, Belgium (tap)","price":"$5.50"}},"3":{"full_address":"1650 Broadway, New York City, NY","location_name":"Iridium","1":{"item_id":"107","item_name":"Wyders Pear Cider","category":"1","detail":"Port Moody, British Columbia (bottle)","price":"$5.25"},"2":{"item_id":"108","item_name":"Hurricane","category":"0","detail":"for a limited time (20oz)","price":"$12.00"},"3":{"item_id":"109","item_name":"Lemon Drop","category":"4","detail":"sour mix, vodka, special ingredients","price":"$4.00"}}}








