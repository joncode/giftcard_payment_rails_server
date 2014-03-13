class FriendPushJob

    @queue = :push

    def self.perform user_id, system
        puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
        if system == 1
            FriendMaker.user_create(user_id)
        else
            FriendMaker.contact_create(user_id)
        end
    end

end