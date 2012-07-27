######################                GIFTS               ######################

#  credit_card          :string(100)
#  redeem_id            :integer
#  status               :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null

# make 100 gifts
# have 50 of them redeemed
# what about using the created_at to put them in microposts
# make ten gifts , then redeem 5 , have the 5 redeems be random
# keep going till you have redeemed 50
# randomly pick a user to give
# randomly pick a user to receive
# randomly pick a provider
# randomly pick an item
messages = ["Happy Birthday!", "Congratulations!", "One good turn deserves another", "have fun tonight", "Cheers"]
notes = ["Shaken not Stirred", "Draft if you got it", "Fireworks!", "Ice Cold", "Surprise please", "Umbrellas" ]
reply = ["thanks dude your rock!", "yo yo yo get over here", "thats so sweet of you ", "there is a season", "Cheers!", "down the hatch!"] 

users_array     = User.all
users_total     = users_array.count

providers_array = Provider.all
providers_total = providers_array.count

items_array     = Item.all
items_total     = items_array.count

messages_total  = messages.count
notes_total     = notes.count
replies = reply.count

gift_hash = {}

5.times do 
  20.times do 
    begin
      receiving_user_index    = rand users_total
      giving_user_index       = rand users_total
    end while receiving_user_index == giving_user_index
      
    giving_user     = users_array[giving_user_index]
    receiving_user  = users_array[receiving_user_index]
  
    provider_index  = rand providers_total 
    provider        = providers_array[provider_index]
  
    item_index      = rand items_total 
    item            = items_array[item_index]   
    menu_item = Menu.find_by_item_id_and_provider_id item, provider
    quantity = rand(5) + 1
    total = menu_item.price.to_i * (quantity + 1)
    message = "" 
    note = ""
    if quantity < 4 
      message_index = rand messages_total
      message = messages[message_index]
    end
    if giving_user_index < 3  
      notes_index = rand notes_total
      note = notes[notes_index]
    end
    gift_hash = {
      giver_id: giving_user.id, 
      receiver_id: receiving_user.id,
      giver_name: giving_user.username ,
      receiver_name: receiving_user.username,
      provider_name: provider.name,
      item_name: item.item_name,
      provider_id: provider.id, 
      item_id: item.id, 
      price: menu_item.price, 
      quantity: quantity, 
      total: total.to_s,
      message: message, 
      special_instructions: note,
      status: 'open',
      category: item.category.to_s
      }
    Gift.create([gift_hash])
  end
  gifts = Gift.where(status: 'open')
  gifts_total = gifts.count
  10.times do 
    index = rand gifts_total
    gift = gifts.slice! index
    gifts_total -= 1
    redeem = Redeem.new
    redeem.gift_id = gift.id
    odds = rand 3
    if odds != 0
      reply_index = rand replies  
      redeem.reply_message = reply[reply_index]
    end
    redeem.redeem_code = rand 10000
    redeem.gift.update_attributes({status:'notified'},{redeem_id: redeem})
    if odds != 2  
      notes_index = rand notes_total
      redeem.special_instructions = notes[notes_index]
    end
    redeem.save
  end
  redeems = Redeem.all
  # find all redeems where the redeem.gift.status == 'notified'
  # find all redeems where the redeem.gift.redeem_id != nil
  redeems_total = redeems.count
  6.times do
     begin
       redeem_index = rand redeems_total
       redeem = redeems.slice! redeem_index
       redeems_total -= 1
     end while redeem.gift.status != 'notified'
     order = Order.new
     order.gift_id = redeem.gift_id
     order.redeem_id = redeem.id
     order.redeem_code = redeem.redeem_code
     order.save
     order.gift.update_attribute(:status, "redeemed")
  end
end












