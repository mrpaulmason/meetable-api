Rails.application.routes.draw do
  	get "/ping", to: proc { [200, {}, ['']] }
  	resource :sms do
	  	collection do
	    	post 'reply'
	    	post 'accept'
	  	end
	end
end
