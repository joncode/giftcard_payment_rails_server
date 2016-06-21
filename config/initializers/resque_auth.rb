Resque::Server.use(Rack::Auth::Basic) do | user, password |
    password == RESQUE_AUTH
end