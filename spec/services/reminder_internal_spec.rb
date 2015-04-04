require 'spec_helper'

describe ReminderInternal do
	it "should find the correct campaigns and campaign items" do
		Campaign.delete_all
		CampaignItem.delete_all
		today = Date.today
		campaign1 = FactoryGirl.create :campaign, live_date: 1.month.ago, close_date: (today + 1.day)
		campaign2 = FactoryGirl.create :campaign, live_date: 1.month.ago, close_date: (today + 1.month)
		campaign3 = FactoryGirl.create :campaign, live_date: 1.month.ago, close_date: 3.days.ago
		cmapaign_item1 = FactoryGirl.create :campaign_item, campaign_id: campaign1.id, expires_at: (today + 1.day)
		cmapaign_item21 = FactoryGirl.create :campaign_item, campaign_id: campaign2.id, expires_at: (today + 1.week)
		cmapaign_item22 = FactoryGirl.create :campaign_item, campaign_id: campaign2.id, expires_at: (today + 1.day)
		cmapaign_item23 = FactoryGirl.create :campaign_item, campaign_id: campaign2.id, expires_at: 3.days.ago
		cmapaign_item3 = FactoryGirl.create :campaign_item, campaign_id: campaign3.id, expires_at: (today + 1.day)

		ResqueSpec.reset!
		mail_data = {
			subject: "Campaign Expiration Notice",
			text: "Campaign #{campaign1.cname} is expiring within 2 days",
			email: "support@itson.me"
		}
		Resque.should_receive(:enqueue).with(MailerInternalJob, mail_data).exactly(1).times.and_return(true)
		ReminderInternal.send_reminders
	end
end