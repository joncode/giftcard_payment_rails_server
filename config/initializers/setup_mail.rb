ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "drinkboard.com",
  :authentication       => "plain",
  :user_name            => "no-reply@itson.me",
  :password             => "CherryOnTop",
  :enable_starttls_auto => true
}

if Rails.env.development?
  ActionMailer::Base.raise_delivery_errors = true
end