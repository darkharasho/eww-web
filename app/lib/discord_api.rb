require 'net/http'
require 'uri'
require 'json'
class DiscordApi
  def initialize(user: nil)
    @user = user
    @creds = Rails.application.credentials.discord
  end

  def get_guilds
    return False unless @user

    client(
      type: "Bearer",
      endpoint: "/users/@me/guilds",
      token: @user.auth_token
    )
  end

  def get_bot_guilds
    client(
      type: "Bot",
      endpoint: "/users/@me/guilds",
      token: @creds[:token]
    )
  end

  def get_guilds_for_display
    user_guilds = self.get_guilds
    bot_guilds = self.get_bot_guilds

    matched_guilds = []
    user_guilds.each do |user_guild|
      if bot_guilds.map{|bg| bg["id"]}.include? user_guild["id"]
        matched_guilds << user_guild
      end
    end

    matched_guilds
  end

  def guild_channels(guild_id:, type: nil)
    response = client(
      type: "Bot",
      endpoint: "/guilds/#{guild_id}/channels",
      token: @creds[:token]
    )

    channel_type = case type
                   when "text_channels"
                     [0, 5]
                   when "voice_channels"
                     [2]
                   when "guild_announcements"
                     [5]
                   when "public_threads"
                     [11]
                   when "forum_channels"
                     [15]
                   else
                     return response
                   end
    if response.class == Hash
      response
    else
      response.map{|channel| channel if channel_type.include?(channel["type"])}.reject{|channel| channel.blank?}
    end
  end

  def guild_roles(guild_id:)
    client(
      type: "Bot",
      endpoint: "/guilds/#{guild_id}/roles",
      token: @creds[:token]
    )
  end

  def guild_build_classes(guild_id:)
    build_forum_channel_config = Config.where(name: "build_forum_channel_id", guild_id: guild_id).first
    threads = client(
      type: "Bot",
      endpoint: "/guilds/#{guild_id}/threads/active",
      token: @creds[:token]
    )
    threads["threads"].select do |thread|
      thread if thread["parent_id"].to_i == build_forum_channel_config.value
    end
  end

  def guild_member(member:, guild:)
    client(
      type: "Bot",
      endpoint: "/guilds/#{guild.id}/members/#{member.discord_id}",
      token: @creds[:token]
    )
  end

  private
  def client(type:, endpoint:, token:)
    api_endpoint = "https://discord.com/api/v10#{endpoint}"
    # Create a URI object with the API endpoint
    uri = URI(api_endpoint)

    Rails.cache.fetch([api_endpoint, token], :expires => 1.hour) do
      # Create an HTTP request
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "#{type} #{token}" # Include your bot token as a Bearer token

      # Make the HTTP request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      # Check the response and parse JSON if successful
      if response.code.to_i == 200
        JSON.parse(response.body)
      else
        JSON.parse(response.body)
      end
    end
  end
end