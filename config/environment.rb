# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Drinkboard::Application.initialize!

BUCKET    = 'drinkboard'
THUMB     = 'drinkboard/thumb'
PORTRAIT  = 'drinkboard/portrait'