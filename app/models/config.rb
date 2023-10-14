class Config < ApplicationRecord
  self.table_name = "config"

  belongs_to :guild, foreign_key: :guild_id

  def pretty_printed_value
    if self.name.include? "channel_id"
      format_channels
    elsif self.name.include? "role_id"
      format_roles
    elsif self.name == "raid_days"
      days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
      self.value.map do |dow|
        "<span class=\"inline-icon\"><i class=\"material-icons\">calendar_month</i>&nbsp#{days_of_week[dow]}</span>"
      end
    elsif self.name == "raid_reminder"
      format_raid_reminder
    elsif self.name == "auto_attendance"
      format_auto_attendance
    elsif self.name == "raid_notification"
      format_raid_notification
    elsif self.name.include? "updates"
      format_update
    else
      Array(JSON.pretty_generate(self.value))
    end
  end

  private
  def format_channels(channel_ids: nil)
    channel_ids = self.value unless channel_ids
    channels = self.guild.channels.select do |channel|
      channel if Array(channel_ids).flatten.include? channel["id"].to_i
    end

    channels.map do |channel|
      "<span class=\"inline-icon\"><i class=\"material-icons\">tag</i>&nbsp#{channel["name"]}</span>"
    end
  end

  def format_roles(roles: nil)
    roles = self.value unless roles
    roles = self.guild.roles.select do |role|
      role if Array(roles).flatten.include? role["id"].to_i
    end

    roles.map do |role|
      "<span class=\"inline-icon\"><i class=\"material-icons\">alternate_email</i>&nbsp#{role["name"]}</span>"
    end
  end

  def format_time
    time = Time.parse("#{self.value["time"]["hour"]}:#{self.value["time"]["minute"]}").strftime("%-k:%M")
    """
    <span class=\"inline-icon\">
      <i class=\"material-icons\">schedule</i>&nbsp#{time} (UTC)
    </span>
    """
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
    """
    <span class=\"inline-icon\">
      <i class=\"material-icons outlined\">#{toggleable.downcase == 'true' ? 'toggle_on' : 'toggle_off'}</i>&nbsp#{toggleable}
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
      <i class=\"material-icons outlined\">table_rows</i>&nbsp#{self.value['table_style']}
    </span>
    """

    html += "<div><b>Hide Empty Rows?:</b></div>"
    html += format_toggle(self.value["hide_empty_rows"])

    html += "</div><div class=\"three columns\">"

    html += "<div><b>Classes:</b></div>"
    classes = self.value["classes"].map do |klass|
      """
      <span class=\"inline-icon\">
        #{self.determine_class_icon(klass)}&nbsp#{klass}
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
    html += "<div><b>Open Tag Roles:</b></div>"
    html += format_roles(roles: self.value["open_tag_role_ids"]).join(" ")
    [html]
  end

  def determine_class_icon(klass)
    case klass.downcase
    when /reaper/
      ActionController::Base.helpers.image_tag("class_icons/Reaper.png", class: "gw2-class-icon")
    when /scourge/
      ActionController::Base.helpers.image_tag("class_icons/Scourge.png", class: "gw2-class-icon")
    when /necro/, /necromancer/
      ActionController::Base.helpers.image_tag("class_icons/Necromancer.png", class: "gw2-class-icon")
    when /harb/, /harbinger/
      ActionController::Base.helpers.image_tag("class_icons/Harbinger.png", class: "gw2-class-icon")
    when /chronomancer/, /chrono/
      ActionController::Base.helpers.image_tag("class_icons/Chronomancer.png", class: "gw2-class-icon")
    when /mirage/
      ActionController::Base.helpers.image_tag("class_icons/Mirage.png", class: "gw2-class-icon")
    when /virt/, /virtuoso/
      ActionController::Base.helpers.image_tag("class_icons/Virtuoso.png", class: "gw2-class-icon")
    when /mes/, /mesmer/
      ActionController::Base.helpers.image_tag("class_icons/Mesmer.png", class: "gw2-class-icon")
    when /rev/, /revenant/
      ActionController::Base.helpers.image_tag("class_icons/Revenant.png", class: "gw2-class-icon")
    when /herald/
      ActionController::Base.helpers.image_tag("class_icons/Herald.png", class: "gw2-class-icon")
    when /vindicator/, /vindi/, /vindy/, /ventari/
      ActionController::Base.helpers.image_tag("class_icons/Vindicator.png", class: "gw2-class-icon")
    when /guard/, /guardian/
      ActionController::Base.helpers.image_tag("class_icons/Guardian.png", class: "gw2-class-icon")
    when /firebrand/, /fb/, /boonbrand/, /healbrand/
      ActionController::Base.helpers.image_tag("class_icons/Firebrand.png", class: "gw2-class-icon")
    when /dh/, /dragonhunter/
      ActionController::Base.helpers.image_tag("class_icons/Dragonhunter.png", class: "gw2-class-icon")
    when /wb/, /willbender/
      ActionController::Base.helpers.image_tag("class_icons/Willbender.png", class: "gw2-class-icon")
    when /engi/, /engineer/
      ActionController::Base.helpers.image_tag("class_icons/Engineer.png", class: "gw2-class-icon")
    when /scrapper/
      ActionController::Base.helpers.image_tag("class_icons/Scrapper.png", class: "gw2-class-icon")
    when /holo/, /holosmith/
      ActionController::Base.helpers.image_tag("class_icons/Holosmith.png", class: "gw2-class-icon")
    when /mech/, /mechanist/
      ActionController::Base.helpers.image_tag("class_icons/Mechanist.png", class: "gw2-class-icon")
    when /ranger/
      ActionController::Base.helpers.image_tag("class_icons/Ranger.png", class: "gw2-class-icon")
    when /soulbeast/, /sb/
      ActionController::Base.helpers.image_tag("class_icons/Soulbeast.png", class: "gw2-class-icon")
    when /druid/
      ActionController::Base.helpers.image_tag("class_icons/Druid.png", class: "gw2-class-icon")
    when /untamed/
      ActionController::Base.helpers.image_tag("class_icons/Untamed.png", class: "gw2-class-icon")
    when /ele/, /elementalist/
      ActionController::Base.helpers.image_tag("class_icons/Elementalist.png", class: "gw2-class-icon")
    when /tempest/
      ActionController::Base.helpers.image_tag("class_icons/Tempest.png", class: "gw2-class-icon")
    when /weaver/
      ActionController::Base.helpers.image_tag("class_icons/Weaver.png", class: "gw2-class-icon")
    when /cata/, /catalyst/
      ActionController::Base.helpers.image_tag("class_icons/Catalyst.png", class: "gw2-class-icon")
    when /war/, /warrior/
      ActionController::Base.helpers.image_tag("class_icons/Warrior.png", class: "gw2-class-icon")
    when /spb/, /spellbreaker/
      ActionController::Base.helpers.image_tag("class_icons/Spellbreaker.png", class: "gw2-class-icon")
    when /zerker/, /berserker/
      ActionController::Base.helpers.image_tag("class_icons/Berserker.png", class: "gw2-class-icon")
    when /bs/, /bladesworn/
      ActionController::Base.helpers.image_tag("class_icons/Bladesworn.png", class: "gw2-class-icon")
    when /thief/, /teef/
      ActionController::Base.helpers.image_tag("class_icons/Thief.png", class: "gw2-class-icon")
    when /deadeye/
      ActionController::Base.helpers.image_tag("class_icons/Deadeye.png", class: "gw2-class-icon")
    when /daredevil/, /dd/
      ActionController::Base.helpers.image_tag("class_icons/Daredevil.png", class: "gw2-class-icon")
    when /specter/, /spectre/
      ActionController::Base.helpers.image_tag("class_icons/Specter.png", class: "gw2-class-icon")
    else
      "<span>✅</span>"
    end
  end
end
