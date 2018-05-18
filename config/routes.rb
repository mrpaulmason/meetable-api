Rails.application.routes.draw do
  # added by administrate gem
  namespace :admin do
    resources :meetings
    resources :messages
    resources :places
    resources :relays
    resources :users
    resources :waitlists

    root to: "meetings#index"
  end

  	get "/ping", to: proc { [200, {}, ['']] }
  	get "/vcard/:relay", to: "vcard#card"
  	match 'meetings/:id/accept', to: 'meeting#accept', via: :post
    match 'meetings/:id/confirm', to: 'meeting#confirm', via: :post
    match 'meetings/:plan_code/locations/:place_id', to: 'meeting#update_locations', via: :post
  	match 'meetings/:id/locations', to: 'meeting#locations', via: :get
    match 'meetings/:id/genrelay', to: 'meeting#genrelay', via: :get
    match 'places', to: 'place#index', via: :get
  	post "/waitlist", to: "waitlist#create"
  	resource :sms do
	  	collection do
	    	post 'reply'
	    	post 'accept'
	  	end
	end
end
