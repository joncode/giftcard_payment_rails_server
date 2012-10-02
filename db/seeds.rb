users = User.all
providers = Provider.all

# bounds
latitude_top    =  40.67517
latitude_bottom =  40.77924
longitute_right = -73.83817
longitute_left  = -74.08330

lat  = rand(4077924 - 4067517) * 0.00001 + 40.67517
long = rand(-7383817 - -7408330) * 0.00001 + -74.08330

latitude_range = 81459 - 65851


users.each do |u|
  lat  = rand(4077924 - 4067517) * 0.00001 + 40.67517
  long = rand(-7383817 - -7408330) * 0.00001 + -74.08330
  Location.create(
    latitude: lat,
    longitude: long,
    user_id: u.id
  )
end

providers.each do |p|
  lat  = rand(4077924 - 4067517) * 0.00001 + 40.67517
  long = rand(-7383817 - -7408330) * 0.00001 + -74.08330
  p.latitude  = lat
  p.longitude = long
  p.save
end