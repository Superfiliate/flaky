class User < ApplicationRecord
  has_many :organization_users
  has_many :organizations, through: :organization_users

  devise :database_authenticatable, :omniauthable, :trackable, omniauth_providers: [ :github ]
  validates :handle, :email, presence: true, uniqueness: true

  def self.find_by_handle(handle)
    find_by("handle LIKE ?", handle)
  end
end
