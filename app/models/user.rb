class User < ApplicationRecord
  has_many :members

  # mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :omniauthable, omniauth_providers: %i[discord]

  has_secure_token :auth_token

  def guild_roles(guild)
    member = Member.find_by(guild_id: guild.id)
    DiscordApi.new(user: self).guild_member(guild: guild, member: member)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if (data = session["devise.discord_data"] && session["devise.discord_data"]["extra"]["raw_info"])
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    image_available = Faraday.get(auth.info.image).status == 200

    @user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.username = auth.info.name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.remote_image_url = auth.info.image if image_available
    end

    Member.where(discord_id: @user.uid).each do |member|
      member.update user_id: @user.id
    end
    @user.update auth_token: auth.credentials.token, auth_expiration: Time.at(auth.credentials.expires_at)

    @user
  end
end
