class Question < ActiveRecord::Base
    attr_accessible :answer, :left, :right

    has_many :answers
    has_many :users , :through => :answers

    def self.get_questions_with_answers(user)
        total = []
        questions = Question.all
        answers = Answer.where(user_id: user.id) 
        puts "in questions w answers"
        questions.each do |question|
            qHash = question.serializable_hash only: [:left, :right]
            qHash["question_id"] = question.id
            if answers.length > 0
                answers.each do |answer|
                    if answer.question_id   == question.id
                        if answer.answer    == question.left
                            qHash["answer"]  = "0"
                        elsif answer.answer == question.right
                            qHash["answer"]  = "1"
                        end  
                    end
                end
            end
            puts " HERE IS THE QHASH #{qHash}"
            total << qHash
        end
    end



    def self.get_six_new_questions(user)
      	# get the question_id's from the answered questions by users
      	answers = Answer.where(user_id: user.id)
      	answered_q_ids = []
        if answers.count > 0
        	answers.each do |a|
        		answered_q_ids << a.question_id
        	end
                # send that array of id's in query to get new questions
            all_qs = Question.all
            new_qs = all_qs.select { |question| !(answered_q_ids.include? question.id) }
                # limit 6
            if new_qs.count < 6
                adds = 6 - new_qs.count
                xtra = all_qs.select { |question| (answered_q_ids.include? question.id) }
                index = 0
                while index < adds
                    six_new_qs << xtra
                    index += 1
                end
            else
                six_new_qs = new_qs[0..5]
            end
        else
            six_new_qs = Question.limit 6
        end

        puts "HERE ARE NEW QUESTIONS #{six_new_qs.inspect}" 	
      	return six_new_qs
    end
end
