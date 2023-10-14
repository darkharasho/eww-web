class GuildsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_guild_access, only: :show

  def index
    @current_user = current_user
    @guilds = []
    DiscordApi.new(user: current_user).get_guilds_for_display.each do |guild|
      @guilds << Guild.find_or_create(guild)
    end
    render :index
  end

  def show
    @guild = Guild.find(params[:id])
    @config = @guild.configs
    render :show
  end

  private
  def ensure_guild_access
    guild = Guild.find(params[:id])
    unless current_user.guild_roles(guild).any? { |role_id| guild.allowed_admin_role_ids.include?(role_id) }
      redirect_to root_path, alert: 'Unauthorized'
    end
  end
end
