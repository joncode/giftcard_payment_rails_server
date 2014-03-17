class BulkContactJob

    @queue = :database

    def self.perform
        puts " ------------- Bulk Contact Processing ------------------"
        bulks = BulkContact.all
        users_getting_push = bulks.map do |b_contact|
            user_id = b_contact.user_id
            resp = BulkContactProcessor.process(contacts: b_contact.normalized_data, user_id: user_id)
            b_contact.destroy
            user_id
        end

        users_getting_push.uniq.each do |u_id|
            FriendPushJob.perform(u_id, 2) #if resp
        end
    end

end