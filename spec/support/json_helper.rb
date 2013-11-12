require 'yajl'

module JsonHelper
  # POST magic -- if a :json parameter is set, then it is serialized and set to the POST body.
  def post(action, parameters = nil, session = nil, flash = nil)
    if parameters.is_a?(Hash) && parameters[:json].present?
      json_params = parameters.delete(:json)
      request.env["RAW_POST_DATA"] = json_params.to_json
      # request.env["CONTENT-TYPE"]  = "application/json"
      super(action, parameters, session, flash)
      request.env.delete("RAW_POST_DATA")
      response
    else
      super
    end
  end

  def json
    if @last_response.nil? || @last_response != response
      @last_response = response
      @last_json = Yajl::Parser.parse(response.body)
    else
      @last_json
    end
  end

  def rrc(status_code)
    response.response_code.should == status_code
    puts response.response_code
    if response.response_code == 200
      json.keys.should include("status", "data")
    end
  end

  def rrc_old(status_code)
    response.response_code.should == status_code
    puts response.response_code
  end


end

RSpec::Rails::ControllerExampleGroup.send(:include, JsonHelper)
