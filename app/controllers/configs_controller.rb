class ConfigsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @config = Config.find(params[:id])
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
    params.require(:config).permit(:value, value: [])
  end
end
