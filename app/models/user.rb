class User < ApplicationRecord
  has_many :organization_users
  has_many :organizations, through: :organization_users

  devise :database_authenticatable, :omniauthable, :trackable, omniauth_providers: [ :github ]
  validates :handle, :email, presence: true, uniqueness: true

  after_create_commit :check_organization_queues

  # Called by the `omniauth_callbacks_controller.rb`
  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.provider = auth.provider
      user.uid = auth.uid

      user.email = auth.info.email
      user.handle = auth.info.nickname
      user.password = SecureRandom.hex(20)
    end
  end

  def self.find_by_handle(handle)
    find_by("handle LIKE ?", handle)
  end

  private

  def check_organization_queues
    # TODO: Could be obviously improved with some SQL...
    Organization.all.each do |organization|
      next unless organization.user_queue.include?(self.handle)

      OrganizationUser.create!(organization:, user: self)
      organization.user_queue.delete(self.handle)
      organization.save!
    end
  end
end
