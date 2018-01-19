class Places
	class << self
        def list(category: '')
            places = Place.all
            output = {locations: []}
            places.each do |place|
            	location = {
                    name: place.name, 
                    address: place.address_1, 
                    city: place.city, 
                    zip: place.zip, 
                    latitude: place.lat, 
                    longitude: place.long
                }
            	output[:locations].push(location)
            end
            output
        end

        def google
            GooglePlaces::Client.new(ENV['GOOGLE_API']) 
        end

        def parse
            hash = YAML.load_file("#{Rails.root}/app/services/places.yml")
            hash.each do |k,v|
                types = v["attributes"].to_a
                categories = v["categories"].to_a

                v["ids"].each do |id|
                    record = google.spot(id)
                    place = Place.find_or_create_by(google_id: id)
                    place.name = record.name
                    place.address_1 = "#{record.address_components.first["short_name"]} #{record.address_components.second["short_name"]}"
                    place.city = record.address_components.third["short_name"]
                    place.zip = record.address_components.last["short_name"]
                    place.lat = record.lat
                    place.long = record.lng
                    #place.types.push(types)
                    #place.categories.push(categories)
                    place.save
                end 
            end
        end
    end
end