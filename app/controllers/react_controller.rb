class ReactController < ApplicationController

	http_basic_authenticate_with name: "developer", password: "gifted", only: :index

	def  index
		puts "Developer Tools #index"
	end






end