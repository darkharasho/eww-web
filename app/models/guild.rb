class Guild < ApplicationRecord
  has_many :configs
  def self.find_or_create(gld)
    @guild = where(id: gld["id"]).first_or_create do |guild|
      guild.name = gld["name"]
      guild.id = gld["id"]
      guild.remote_image_url = GuildHelper.get_guild_icon_url(gld)
    end
  end

  def channels
    DiscordApi.new.guild_channels(guild_id: self.id)
  end

  def forum_channels
    DiscordApi.new.guild_channels(guild_id: self.id, type: "forum_channels")
  end

  def text_channels
    DiscordApi.new.guild_channels(guild_id: self.id, type: "text_channels")
  end

  def announcement_channels
    DiscordApi.new.guild_channels(guild_id: self.id, type: "guild_announcements")
  end

  def allowed_admin_role_ids
    self.configs.find_by(name: "allowed_admin_role_ids").value
  end

  def roles
    DiscordApi.new.guild_roles(guild_id: self.id)
  end
end
