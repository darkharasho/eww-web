class GuildsController < ApplicationController
  before_action :authenticate_user!
  def index
    @current_user = current_user
    render :index
  end
end
