class WaitlistController < ApplicationController
	def create
	    waitlist = Waitlist.new(waitlist_params)
	    if waitlist.save
	      render :json => APIResponse.response(type: "ok")
	    else
	      render :json => APIResponse.response(type: "invalid_email")
	    end

	    render :json => APIResponse.response(type: "error")
	end

	private
    # Only allow a trusted parameter "white list" through.
    def waitlist_params
      params.permit(:email, :survey)
    end
end
