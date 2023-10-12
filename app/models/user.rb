class User < ApplicationRecord
  has_many :members
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[discord]

  mount_uploader :avatar, AvatarUploader

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

      Member.where(discord_id: user.uid).each do |member|
        member.update user_id: user.id
      end
    end
  end
end
