class BulkEmail < ActiveRecord::Base
end
# == Schema Information
#
# Table name: bulk_emails
#
#  id          :integer         not null, primary key
#  data        :text
#  processed   :boolean         default(FALSE)
#  proto_id    :integer
#  provider_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  at_user_id  :integer
#

