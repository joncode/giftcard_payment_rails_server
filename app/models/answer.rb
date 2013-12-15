class Answer < ActiveRecord::Base
	#attr_accessible :answer, :question_id, :user_id

	belongs_to :user
	belongs_to :question

	validates_presence_of :user_id, :answer, :question_id

	def self.save_these(answered_questions, user)

		answered_questions.each do |a|
			if answer = Answer.where(user_id: user.id, question_id: a["question_id"].to_i).pop
				if answer.answer != a["answer"]
					answer.update_attributes(answer: a["answer"])
				end
			else
				a["user_id"] = user.id
				a.delete_if {|k| ["left", "right"].include? k }
				answer 		 = Answer.create(a)
			end
		end

	end

end
# == Schema Information
#
# Table name: answers
#
#  id          :integer         not null, primary key
#  answer      :string(255)
#  user_id     :integer
#  question_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

