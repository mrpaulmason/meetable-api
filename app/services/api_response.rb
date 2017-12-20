class APIResponse
    class << self
        def response(type:)
            hash = YAML.load_file("#{Rails.root}/app/services/api_response.yml")
            {status: hash[type]["status"], message: hash[type]["message"]}
        end
    end
end