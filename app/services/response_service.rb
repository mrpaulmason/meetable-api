class ResponseService
	def initialize(user:, wit:)
		@user = user
		@wit = wit
	end

	def new_meeting
		name = @wit[:_text].split(" ").second.capitalize
		date_time = @wit[:entities].has_key?(:datetime) ? @wit[:entities][:datetime].first[:value] : nil
		location_type = @wit[:entities].has_key?(:location_type) ? @wit[:entities][:location_type].first[:value] : nil
		if location_type.nil?
			case @wit[:_text].split(" ").last.strip
			when "b"
				location_type = "bar"
			when "c"
				location_type = "coffee shop"
			when "r"
				location_type = "restaurant"
			end
		end
		
		m = Meeting.new(user_id: @user.id, date_time: date_time, location_type: location_type)
		m.save
		["Send this link to #{name}:","http://meetable.ai/#{m.share_code}"]
	end
end