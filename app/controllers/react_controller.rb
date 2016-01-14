class ReactController < ApplicationController

	http_basic_authenticate_with name: "dhh", password: "secret", only: :index

	def  index
		puts "Developer Tools #index"
	end






end