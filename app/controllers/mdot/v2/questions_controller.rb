class Mdot::V2::QuestionsController < JsonController
    before_filter :authenticate_customer

    rescue_from JSON::ParserError, :with => :bad_request

    def index
        questions  = Question.get_questions_with_answers(@current_user)
        success questions
        respond
    end

    def update
        data = if params["data"].kind_of?(String)
            JSON.parse(params["data"])
        else
            params["data"]
        end

        return nil  if data_not_array?(data)
        answers_params = ary_strong_params(data)
        return nil  if hash_empty?(answers_params)

        if Answer.save_these(answers_params, @current_user)
            success(Question.get_questions_with_answers(@current_user))
        else
            fail database_error_general
        end
        respond
    end

private

    def ary_strong_params data_ary
        data_ary.map do |data|
            strong_param data
        end
    end

    def strong_param data_hsh
        allowed = ["question_id", "answer"]
        data_hsh.select{ |k,v| allowed.include? k }
    end

end
