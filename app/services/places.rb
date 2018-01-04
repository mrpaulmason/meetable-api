class Places
	class << self
        def list(category: '')
            hash = YAML.load_file("#{Rails.root}/app/services/places.yml")
            output = {locations: []}
            hash.each do |k,v|
            	location = {name: k, address: v["address"], latitude: v["latitude"], longitude: v["longitude"]}
            	output[:locations].push(location)
            end
            output
        end
    end
end