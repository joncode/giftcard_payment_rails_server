# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
User.create(username: 'admin', email: 'test@test.com', admin: true, password: 'testtest', password_confirmation: 'testtest', first_name: 'Larry', last_name: 'Page' , city: 'New York', state: 'NY', zip: 11238, phone: '1-646-493-4870', address: '1 Google Drive', credit_number: '4444444444444444')
