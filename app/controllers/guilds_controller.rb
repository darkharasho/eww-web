class GuildsController < ApplicationController
  before_action :authenticate_user!
  def index
    @current_user = current_user
    # binding.pry
    render :index
  end
end
