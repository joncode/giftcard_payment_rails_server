class Question < ActiveRecord::Base
  attr_accessible :answer, :left, :right

  has_many :answers
  has_many :users , :through => :answers


  def self.get_six_new_questions(user)
  	# get the question_id's from the answered questions by users
  	answers = Answer.where user_id: user
  	answered_question_ids = []
  	answer.each do |a|
  		answered_q_ids << a.question_id
  	end
  	
  	# send that array of id's in query to get new questions
  	all_qs = Question.all
  	new_qs = all_qs.select { |question| !(answered_q_ids.include? question.id) }
  	# limit 6
  	six_new_qs = new_qs[0..5]
  	return six_new_qs
  end
end
