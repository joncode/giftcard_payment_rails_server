class Answer < ActiveRecord::Base
  attr_accessible :answer, :question_id, :user_id

  belongs_to :user
  belongs_to :question

  validates_presence_of :user_id, :answer, :question_id

  def self.save_these(answered_questions, user)
  	puts "SAVE THESE ANSWERS #{answered_questions}"
  	answered_questions.each do |a|
  		if answer = Answer.where(user_id: user.id, question_id: a["question_id"]).pop
  			if answer.answer != a["answer"]
  				answer.update_attributes(answer: a["answer"])
          puts "updated answer = #{answer.inspect}"
  			end
  		else
  			a["user_id"]= user.id
  			answer = Answer.create(a)
        puts "created answer = #{answer.inspect} "
      end
  	end
  end

  def self.where *args, &block
    puts "here we go"
    r = super
    puts "hey => #{r.inspect}"
    r
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

