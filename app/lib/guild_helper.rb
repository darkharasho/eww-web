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
end