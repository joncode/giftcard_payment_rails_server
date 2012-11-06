class Answer < ActiveRecord::Base
  attr_accessible :answer, :question_id, :user_id

  belongs_to :user
  belongs_to :question

  validates_presence_of :user_id, :answer, :question_id

  def self.save_these(answered_questions, user)
  	puts "SAVE THESE ANSWERS #{answered_questions.inspect}"
  	answered_questions.each do |a|
  		Answer.create(user_id: user.id, question_id: a.question_id, answer: a.answer)   
  	end
  end
end
