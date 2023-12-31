class Config < ApplicationRecord
  self.table_name = "config"
  validate :config_validation

  belongs_to :guild, foreign_key: :guild_id

  def pretty_printed_value
    return nil if self.value == nil

    if self.name.include? "forum"
      format_channels(forum: true)
    elsif self.name.include? "channel_id"
      format_channels
    elsif self.name.include? "role_id"
      format_roles
    elsif self.name == "raid_days"
      days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
      self.value.map do |dow|
        "<span class=\"inline-icon\"><i class=\"material-icons twotone\">calendar_month</i>&nbsp#{days_of_week[dow]}</span>"
      end
    elsif self.name == "raid_reminder"
      format_raid_reminder
    elsif self.name == "auto_attendance"
      format_auto_attendance
    elsif self.name == "raid_notification"
      format_raid_notification
    elsif self.name.include? "updates"
      format_update
    elsif self.name. == "disabled_modules"
      format_modules
    else
      Array(JSON.pretty_generate(self.value))
    end
  end

  private
  def format_channels(channel_ids: nil, forum: false)
    channel_ids = self.value unless channel_ids
    channels = self.guild.channels.select do |channel|
      channel if Array(channel_ids).flatten.include? channel["id"].to_i
    end

    channels.map do |channel|
      if forum
        "<span class=\"inline-icon\"><i class=\"material-icons twotone\">forum</i>&nbsp#{channel["name"]}</span>"

      else
        "<span class=\"inline-icon\"><i class=\"material-icons twotone\">tag</i>&nbsp#{channel["name"]}</span>"
      end
    end
  end

  def format_roles(roles: nil)
    roles = self.value unless roles
    roles = self.guild.roles.select do |role|
      role if Array(roles).flatten.include? role["id"].to_i
    end

    roles.map do |role|
      "<span class=\"inline-icon\"><i class=\"material-icons twotone\">alternate_email</i>&nbsp#{role["name"]}</span>"
    end
  end

  def format_time
    time = Time.parse("#{self.value["time"]["hour"]}:#{self.value["time"]["minute"]}").strftime("%-k:%M")
    """
    <span class=\"inline-icon\">
      <i class=\"material-icons twotone\">schedule</i>&nbsp#{time} (UTC)
    </span>
    """
  end

  def format_modules
    EwwBotApi.modules.map do |mod|
      icon = value.include?(mod) ? 'toggle_off' : 'toggle_on'
      style = value.include?(mod) ? 'outlined' : 'twotone'
      """
      <span class=\"inline-icon\">
        <i class=\"material-icons #{style}\">#{icon}</i>&nbsp#{mod}
      </span>
      """
    end
  end

  def format_update
    html = ""
    html += "<div><b>Enabled?:</b></div>"
    html += format_toggle(self.value["enabled"])
    html += "<div><b>Channel:</b></div>"
    html += format_channels(channel_ids: self.value["channel_id"]).join(" ")

    [html]
  end

  def format_toggle(toggleable)
    icon = toggleable.downcase == 'true' ? 'toggle_on' : 'toggle_off'
    style = toggleable.downcase == 'true' ? 'twotone' : 'outlined'
    """
    <span class=\"inline-icon\">
      <i class=\"material-icons #{style}\">#{icon}</i>&nbsp#{toggleable}
    </span>
    """
  end

  def format_raid_reminder
    html = "<div class=\"row\"><div class=\"four columns\">"
    html += "<div><b>Channel:</b></div>"
    html += format_channels.join(" ")

    html += "<div><b>Roles:</b></div>"
    html += format_roles.join(" ")
    html += "<div><b>Time:</b></div>"
    html += format_time

    html += "<div><b>Table Style:</b></div>"
    html += """
    <span class=\"inline-icon\">
      <i class=\"material-icons twotone\">table_rows</i>&nbsp#{self.value['table_style']}
    </span>
    """

    html += "<div><b>Hide Empty Rows?:</b></div>"
    html += format_toggle(self.value["hide_empty_rows"])

    html += "</div><div class=\"three columns\">"

    html += "<div><b>Classes:</b></div>"
    classes = self.value["classes"].map do |klass|
      """
      <span class=\"inline-icon\">
        #{GuildHelper.determine_class_icon(klass)}&nbsp#{klass}
      </span>
      """
    end
    html += classes.join(" ")

    html += "</div></div>"

    [html]
  end

  def format_auto_attendance
    html = ""
    html += "<div><b>Enabled?:</b></div>"
    html += format_toggle(self.value["enabled"])
    html += "<div><b>Channel:</b></div>"
    html += format_channels.join(" ")
    html += "<div><b>Time:</b></div>"
    html += format_time
    [html]
  end

  def format_raid_notification
    html = ""
    html += "<div><b>Roles:</b></div>"
    html += format_roles(roles: self.value["role_ids"]).join(" ")
    html += format_channels(channel_ids: [self.value["closed_raid_channel_id"]]).join(" ")
    html += "<div><b>Open Tag Roles:</b></div>"
    html += format_roles(roles: self.value["open_tag_role_ids"]).join(" ")
    html += format_channels(channel_ids: [self.value["open_raid_channel_id"]]).join(" ")
    [html]
  end

  def config_validation
    case name
    when "raid_reminder"
      errors.add(:hour, "cannot be blank") if value["time"]["hour"].blank?
      errors.add(:minute, "cannot be blank") if value["time"]["minute"].blank?
      errors.add(:classes, "cannot be blank") if value["classes"].blank?
      errors.add(:roles, "cannot be blank") if value["role_ids"].blank?
      errors.add(:channel, "cannot be blank") if value["channel_id"].blank?
      errors.add(:hide_empty_rows, "cannot be blank") if value["hide_empty_rows"].blank?
      errors.add(:table_style, "cannot be blank") if value["table_style"].blank?
    when "build_update_channel_id", "build_forum_channel_id", "review_forum_channel_id"
      errors.add(:channel, "cannot be blank") if value.blank?
    when "raid_days"
      errors.add(:days, "cannot be blank") if value.blank?
    when "guild_member_role_id", "build_manager_role_ids", "allowed_admin_role_ids", "commander_role_ids"
      errors.add(:roles, "cannot be blank") if value.blank?
    when "auto_attendance"
      errors.add(:enabled, "cannot be blank") if value["enabled"].blank?
      errors.add(:channel, "cannot be blank") if value["channel_id"].blank?
      errors.add(:hour, "cannot be blank") if value["time"]["hour"].blank?
      errors.add(:minute, "cannot be blank") if value["time"]["minute"].blank?
    when "arcdps_updates", "game_updates"
      errors.add(:enabled, "cannot be blank") if value["enabled"].blank?
      errors.add(:channel, "cannot be blank") if value["channel_id"].blank?
    end
  end
end
