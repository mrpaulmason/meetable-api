class ResponseService
	def initialize(user:, message:)
		@user = user
	end

	def new_meeting(name:)
		m = Meeting.new(user_id: @user.id)
		m.save
		return ["Date/time & place type?","http://meetable.com/#{m.share_code}"]
	end
end