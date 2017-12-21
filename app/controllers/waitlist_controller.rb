class WaitlistController < ApplicationController
	def create
	    waitlist = Waitlist.new(waitlist_params)
	    if waitlist.save
	      render :json => APIResponse.response(type: "ok") and return
	    else
	      render :json => APIResponse.response(type: "invalid_email") and return 
	    end

	    render :json => APIResponse.response(type: "error") and return 
	end

	private
    
    def waitlist_params
      params.permit(:email, :survey)
    end
end
