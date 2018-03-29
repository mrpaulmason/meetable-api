Rails.application.routes.draw do
  	get "/ping", to: proc { [200, {}, ['']] }
  	get "/vcard/:relay", to: "vcard#card"
  	match 'meetings/:id/accept', to: 'meeting#accept', via: :post
    match 'meetings/:id/confirm', to: 'meeting#confirm', via: :post
  	match 'meetings/:id/locations', to: 'meeting#locations', via: :get
  	post "/waitlist", to: "waitlist#create"
  	resource :sms do
	  	collection do
	    	post 'reply'
	    	post 'accept'
	  	end
	end
end
