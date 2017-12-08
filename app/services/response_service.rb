class ResponseService
	def initialize(user:, message:)
	end

	def new_meeting(name:)
		Meeting.new(user_id: user.id)
		return ["Date/time & place type?"]
	end
end