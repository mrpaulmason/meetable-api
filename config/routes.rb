Rails.application.routes.draw do
  	get "/ping", to: proc { [200, {}, ['']] }
  	get "/vcard", to: "vcard#card"
  	match 'meetings/:id/accept', to: 'meeting#accept', via: :post
  	resource :sms do
	  	collection do
	    	post 'reply'
	    	post 'accept'
	  	end
	end
end
