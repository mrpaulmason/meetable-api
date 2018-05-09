class PlaceController < ApplicationController
  def index
      if params[:category]
        render :json => Places.list(category: params[:category])
      else
        render :json => Places.list()
      end
  end
end
