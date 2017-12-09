class ResponseService
	def initialize(user:, message:)
		@user = user
		@message = message
	end

	def new_meeting
		arr = @message.split(",")
		m = Meeting.new(user_id: @user.id, time: arr[2], date: arr[3], location_type: arr[4])
		m.save
		["Send this link to #{arr[1].strip.capitalize}:","http://meetable.com/#{m.share_code}"]
	end
end