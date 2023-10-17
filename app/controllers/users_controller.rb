class UsersController < ApplicationController
  before_action :authenticate_user!
  def set_timezone
    current_user.update(timezone: params[:timezone])
    head :no_content # Respond with a 204 No Content status
  end

  private
  def user_params
    params.require(:user).permit(:timezone)
  end
end