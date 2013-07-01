Resque::Server.use(Rack::Auth::Basic) do | user, password |
    password == "Dboard77"
end