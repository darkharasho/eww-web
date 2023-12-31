class ConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_guild_access

  def edit
    @config = Config.find(params[:id])

    if %w[raid_notification build_manager_role_ids allowed_admin_role_ids raid_reminder commander_role_ids].include? @config.name
      roles = @config.guild.roles
      if roles.class == Hash && roles.dig("message") == "You are being rate limited."
        redirect_to guild_path(@config.guild), alert: "Rate limit reached. Try again later."
        return
      else
        @role_multiselect = roles.map do |role|
          [role["name"], role["id"]]
        end
      end
    end

    if %w[auto_attendance raid_reminder].include?(@config.name)
      time_string = "#{@config.value["time"]["hour"]}:#{@config.value["time"]["minute"]}"
      @converted_time = Time.zone.parse(time_string).in_time_zone(current_user.timezone)
    end

    if %w[auto_attendance raid_reminder raid_notification].include?(@config.name)
      text_channels = @config.guild.text_channels
      if text_channels.class == Hash && text_channels.dig("message") == "You are being rate limited."
        redirect_to guild_path(@config.guild), alert: "Rate limit reached. Try again later."
        return
      else
        @channel_select = text_channels.map{|channel| [channel["name"], channel["id"]]}
      end
    end

    if %w[raid_reminder].include? @config.name
      @build_classes = @config.guild.build_classes
      store_selected = []

      options = ''
      options << ActionController::Base.helpers.content_tag(:optgroup, label: "Guild Builds", "data-closable" => "close") do ||
        @build_classes.each do |item|
          selected = @config.value["classes"].any? { |cls| cls == item }
          store_selected << item if selected
          classed_item = GuildHelper.determine_class_icon(item)
          ActionController::Base.helpers.concat(ActionController::Base.helpers.content_tag(:option, item, value: item, selected: selected, "data-html": "#{classed_item}&nbsp#{item}"))
        end
      end

      options << ActionController::Base.helpers.content_tag(:optgroup, label: "Other GW2 Classes", "data-closable" => "close") do ||
        GuildHelper.all_classes.each do |item|
          selected = @config.value["classes"].any? { |cls| cls == item }
          classed_item = GuildHelper.determine_class_icon(item)
          disabled = @build_classes.include?(item)
          ActionController::Base.helpers.concat(ActionController::Base.helpers.content_tag(:option, item, value: disabled ? "#{item}-disabled" : item, selected: selected, disabled: disabled, "data-html": "#{classed_item}&nbsp#{item}"))
        end
      end

      options << ActionController::Base.helpers.content_tag(:optgroup, label: "Other", "data-closable" => "close") do ||
        ["Other", "None of the Above", "Not Listed"].each do |item|
          selected = @config.value["classes"].any? { |cls| cls == item }
          selected = false if store_selected.any? { |cls| cls == item }
          store_selected << item if selected
          ActionController::Base.helpers.concat(ActionController::Base.helpers.content_tag(:option, item, value: item, selected: selected))
        end
      end
      @guild_build_options = options.html_safe
    end

    render :edit
  end

  def update
    @config = Config.find params[:id]
    response = ""
    respond_to do |format|
      if config_params[:value].class == Array
        if config_params[:value].reject{|c| c.blank?}.all? { |str| /\A\d+\z/ === str }
          @config.update value: config_params[:value].reject{|c| c.blank?}.map(&:to_i)
        else
          @config.update value: config_params[:value].reject{|c| c.blank?}
          if @config.name == "disabled_modules"
            response = EwwBotApi.reload_modules
          end
        end
        format.html { redirect_to @config.guild, notice: "Config updated successfully | #{response}" }
      elsif @config.update value: eval(config_params[:value])
        if @config.name == "auto_attendance" || @config.name == "raid_reminder"
          EwwBotApi.reload_task(@config.name)
        end
        format.html { redirect_to @config.guild, notice: 'Config updated successfully' }
      else
        format.html { redirect_to edit_config_path(@config), alert: @config.errors.full_messages.join(" | ")}
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
        role_ids: params["role_ids"]&.map(&:to_i),
        closed_raid_channel_id: params["closed_raid_channel_id"][0].to_i,
        open_tag_role_ids: params["open_tag_role_ids"]&.map(&:to_i),
        open_raid_channel_id: params["open_raid_channel_id"][0].to_i
      }.to_s
    when "auto_attendance"
      time_string = "#{params["time"]["time(4i)"]}:#{params["time"]["time(5i)"]}"
      specific_time = Time.find_zone(current_user.timezone).strptime(time_string, "%H:%M").utc
      params[:config] = {}
      params[:config][:value] = {
        enabled: params["enabled"],
        channel_id: params["channel_id"] ? params["channel_id"].to_i : params["channel_id"],
        time: {
          hour: specific_time.hour,
          minute: specific_time.min
        }
      }.to_s
    when "raid_reminder"
      time_string = "#{params["time"]["time(4i)"]}:#{params["time"]["time(5i)"]}"
      specific_time = Time.find_zone(current_user.timezone).strptime(time_string, "%H:%M").utc
      params[:config] = {}
      params[:config][:value] = {
        hide_empty_rows: params["hide_empty_rows"],
        table_style: params["table_style"],
        channel_id: params["channel_id"] ? params["channel_id"].to_i : params["channel_id"],
        time: {
          hour: specific_time.hour,
          minute: specific_time.min
        },
        role_ids: params["role_ids"]&.map(&:to_i),
        classes: params["build_classes"]
      }.to_s
    when "arcdps_updates", "game_updates"
      params[:config] = {}
      params[:config][:value] = {
        enabled: params["enabled"],
        channel_id: params["channel_id"] ? params["channel_id"].to_i : params["channel_id"]
      }.to_s
    end
    params
  end

  private
  def ensure_guild_access
    guild = Config.find(params[:id]).guild
    unless current_user.guild_roles(guild).any? { |role_id| guild.allowed_admin_role_ids.include?(role_id) }
      redirect_to root_path, alert: 'Unauthorized'
    end
  end
end
