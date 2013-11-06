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

  def compare_keys(json_hsh, expected_keys)
    if json_hsh.keys.count > expected_keys.count
      over_keys = json_hsh.keys - expected_keys
      puts "Too many keys !!! #{over_keys}"
    elsif json_hsh.keys.count < expected_keys.count
      over_keys = expected_keys = json_hsh.keys
      puts "Missing these keys !!! #{over_keys}"
    end
    json_hsh.keys.count.should == expected_keys.count
    expected_keys.each do |key|
      json_hsh.has_key?(key).should be_true
    end
  end

end

RSpec::Rails::ControllerExampleGroup.send(:include, JsonHelper)
