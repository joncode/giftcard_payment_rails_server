#Server Code for the ItsOnMe App


##Spec notes

	1) all factory methods are in spec/factories

	2) FactoryGirl.create ?
		use one of the factories instead, they will give u better data

	###when creating users in tests :

		(top of *_spec.rb file)
			 ` include MocksAndStubs `

		(in :it method)
			 ` resque_stubs(confirm_email: nil, register_push: nil, subscribe_email: nil, mailer_job: nil) `

		you may leave off all the args and all those items will be stubbed
		to remove the stubb off anyone (for example :confirm_email)
			 ` resque_stubs(confirm_email: true) `

	###when creating a Merchant or a Provider

		(top of *_spec.rb file)
			 ` include MerchantFactory `

		(in :it method)
			 ` var merchant = make_merchant_provider('merchant_name') `

	###when creating a Gift Sale
		(top of *_spec.rb file)
			 ` include GiftModelFactory

		(in :it method)
			 ` var gift = make_gift_sale(giver, receiver, value, provider_id) `

##Redis notes

	run the redis server
	1. in the command line
		redis-server
	2. start the rails server
		rs
	3. start the resque rake task
		QUEUE=* rake resque:work

== README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.




