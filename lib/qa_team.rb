module QaTeam

    def self.erase
        # have an array of merchant tools admin tokens
        admin_tokens = ["3Yo6C8EtHxAFqT0aACnfhg", "0OUzZks-fC6yT0hEBR1fJg", "FdwgC5gATvuP-oRODEsl0g", "FdwgC5gATvuP-oRODEsl0g", "3Yo6C8EtHxAFqT0aACnfhg", "f0eNS804bPgcKEGqMPrrOw", "PCartgKMRox7TPj6JQkO9g", "0OUzZks-fC6yT0hEBR1fJg", "2FQsCBCNjAqIMmGgtcFv_A", "Fc6AS9gHbwXlg7RpXVmwZA", "AetvlQ5Bb8xBs-28vHDZlQ", "JEUPZ5cIMcTMkaoHYh7k7g", "2C1uuKVMToNX95J81MPWYA"]
        # get the database of users
        users = User.all.to_a
        deleted_users = []
        # loop thru each user
        users.each do |user|
            # print out user name
            puts " #{u.name} #{u.email} "
            # compare user token to admin token
            # print out if user has admin token in that system
            if admin_tokens.include? user.remember_token
                puts "User is Admin"
            else
                puts "user is not Admin"
            end
            # ask me for y/n to delete
            print "Delete User ? -> (y/n) "
            response = gets.chomp.downcase
            if response == 'y'
                deleted_users << user.destroy
            end
        end
        return deleted_users.map {|u| " #{u.name} #{u.email} "}.join('|')
    end

end