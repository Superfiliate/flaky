class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :omniauthable, :trackable, omniauth_providers: [:github]

  # Called by the `omniauth_callbacks_controller.rb`
  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      puts("----")
      puts("----")
      puts(auth.inspect)
      puts("----")
      puts("----")

      user.provider = auth.provider
      user.uid = auth.uid

      # user.name = auth.info.name
      user.email = auth.info.email
      user.password = SecureRandom.hex(20)
    end
  end
end
