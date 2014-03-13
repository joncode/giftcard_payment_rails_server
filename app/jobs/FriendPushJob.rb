class FriendPushJob

    @queue = :push

    def self.perform user_id, system
        puts "^^^^^^^^^^^ FRIENDS PUSH^^^^^^^^^^^^^^^^^^"
        if system == 1
            FriendMaker.user_create(user_id)
            r_to_pushes = Relationship.where(pushed: false, follower_id: user_id)
            self.loop_contact_friend r_to_pushes
        else
            FriendMaker.contact_create(user_id)
            r_to_pushes = Relationship.where(pushed: false, followed_id: user_id)
            self.loop_user_friends r_to_pushes
        end
    end

private

    def self.loop_contact_friend r_to_pushes
        if r_to_pushes.count > 0
            user_id = r_to_pushes[0].follower_id
            user = User.find user_id
            r_to_pushes.each do |r_push|
                receiver = User.find(r_push.followed_id)
                self.send_push_contact_friend(user, receiver)
            end
            Relationship.pushed(r_to_pushes)
        end
    end

    def self.send_push_contact_friend(user, receiver)
        badge = Gift.get_notifications(receiver)
        payload = self.format_payload_contact_friend(user, badge, receiver)
        Urbanairship.push(payload)
    end

    def self.format_payload_contact_friend(user, badge, receiver)
        { :aliases => [receiver.ua_alias],:aps => { :alert => "#{user.username} can now send you a drink", :badge => badge, :sound => 'pn.wav' },:alert_type => 4 }
    end

    def self.loop_user_friends r_to_pushes
        if r_to_pushes.count > 0
            user_id = r_to_pushes[0].followed_id
            user = User.find user_id
            self.send_push_user_friend(user, r_to_pushes.count)
        end
    end

    def self.send_push_user_friend(user, count)
        badge = Gift.get_notifications(user)
        payload = self.format_payload_user_friend(user, badge, count)
        Urbanairship.push(payload)
    end

    def self.format_payload_user_friend(user, badge, count)
        { :aliases => [user.ua_alias],:aps => { :alert => "You have #{count} friends on ItsOnMe", :badge => badge, :sound => 'pn.wav' },:alert_type => 5 }
    end
end