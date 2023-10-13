class ConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_guild_access

  def edit
    @config = Config.find(params[:id])

    if %w[raid_notification build_manager_role_ids allowed_admin_role_ids].include? @config.name
      @role_multiselect = @config.guild.roles.map do |role|
        [role["name"], role["id"]]
      end
    end
    if ["auto_attendance"].include? @config.name
      @channel_select = @config.guild.text_channels.map{|channel| [channel["name"], channel["id"]]}
    end

    render :edit
  end

  def update
    @config = Config.find params[:id]
    respond_to do |format|
      if config_params[:value].class == Array
        @config.update value: config_params[:value].reject{|c| c.blank?}.map(&:to_i)
        format.html { redirect_to @config.guild, notice: 'Config updated successfully' }
      elsif @config.update value: eval(config_params[:value])
        format.html { redirect_to @config.guild, notice: 'Config updated successfully' }
      else
        format.html { redirect_to guild_path(@config.guild)}
      end
    end
  end

  private

  def config_params
    formatted_params = format_for_config(params)
    value = formatted_params[:config][:value]

    if value.is_a?(Array)
      formatted_params.require(:config).permit(value: [])
    elsif value.is_a?(Hash)
      formatted_params.require(:config).permit(value: {})
    else
      formatted_params.require(:config).permit(:value)
    end
  end

  def format_for_config(params)
    case @config.name
    when "raid_notification"
      params[:config] = {}
      params[:config][:value] = {
        role_ids: params["role_ids"].map(&:to_i),
        open_tag_role_ids: params["open_tag_role_ids"].map(&:to_i)
      }.to_s
    when "auto_attendance"
      params[:config] = {}
      params[:config][:value] = {
        enabled: params["enabled"],
        channel_id: params["channel_id"].to_i,
        time: {
          hour: params["time"]["time(4i)"],
          minute: params["time"]["time(5i)"]
        }
      }.to_s
    end
    params
  end
end
