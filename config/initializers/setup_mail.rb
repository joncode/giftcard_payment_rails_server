ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :authentication       => "plain",
  :user_name            => "noreplydrinkboard",
  :password             => "noreplydboard",
  :enable_starttls_auto => true
}

if Rails.env.development?
  ActionMailer::Base.default_url_options[:host] = "0.0.0.0:3000"
else
  ActionMailer::Base.default_url_options[:host] = "drinkboard.herokuapp.com"
end