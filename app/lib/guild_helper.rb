class GuildHelper
  def self.get_guild_icon_url(guild)
    "https://cdn.discordapp.com/icons/#{guild["id"]}/#{guild["icon"]}.png"
  end

  def self.get_guild_by_id(id)
    guilds = DiscordApi.new.get_bot_guilds

    guilds.each do |guild|
      if guild["id"] == id
        return guild
      end
    end
  end

  def self.all_classes
    %w[Mesmer Mirage Chronomancer Virtuoso Guardian Dragonhunter Firebrand Willbender Necromancer Reaper Scourge Harbinger Ranger Druid Soulbeast Untamed Elementalist Tempest Weaver Catalyst Warrior Berserker Spellbreaker Bladesworn Thief Daredevil Deadeye Specter Engineer Holosmith Scrapper Mechanist Revenant Renegade Herald Vindicator]
  end

  def self.determine_class_icon(klass)
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
    when /renegade/, /rene/
      ActionController::Base.helpers.image_tag("class_icons/Renegade.png", class: "gw2-class-icon")
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