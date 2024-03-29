class Wit
	include HTTParty
	require 'uri'

	base_uri 'https://api.wit.ai'

	class << self 
		def headers 
			{ 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{ENV['WIT_TOKEN']}" }
		end

		def version
			'20171209'
		end

		def message(message:)
			response = get("/message?v=#{version}&q=#{URI.encode(message)}", :headers => headers)
			response.parsed_response.deep_symbolize_keys!
		end

		def add_relay
			body = []
			keywords = File.readlines("#{Rails.root}/app/models/nlp/relay.txt")
			keywords.each do |k|
				e = {:text => k.strip, :entities => [{:entity => 'intent', :value => 'relay'}]}
				body << e
			end
			post("/samples?v=#{version}", :body => body.to_json, :headers => headers)
		end

		def add_new
			body = []
			keywords = File.readlines("#{Rails.root}/app/models/nlp/new.txt")
			keywords.each do |k|
				e = {:text => k.strip, :entities => [{:entity => 'intent', :value => 'new'}]}
				body << e
			end
			post("/samples?v=#{version}", :body => body.to_json, :headers => headers)
		end

		def add_entities 
			entities = ["location_type","first_name"]
			entities.each do |e|
				body = {:id => e.strip}
				post("/entities?v=#{version}", :body => body.to_json, :headers => headers)
			end
		end

		def add_location_type
			body = []
			b = {:text => "b", :entities => [:entity => 'location_type', :value => "bar"]}
			body << b
			c = {:text => "c", :entities => [:entity => 'location_type', :value => "coffee"]}
			body << c
			r = {:text => "r", :entities => [:entity => 'location_type', :value => "restaurant"]}
			body << r

			post("/samples?v=#{version}", :body => body.to_json, :headers => headers)
		end

		def add_names
			body = []
			keywords = File.readlines("#{Rails.root}/app/models/nlp/first_names.txt")
			keywords.each do |k|
				e = {:text => k.downcase.strip, :entities => [{:entity => 'first_name', :value => k.downcase.strip}]}
				body << e
			end
			post("/samples?v=#{version}", :body => body.to_json, :headers => headers)
		end

	end
end