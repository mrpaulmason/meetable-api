class PlaceController < ApplicationController
  def index
      render :json => Places.list(category: params[:category], attribute: params[:attribute])
  end
end
