class Organization < ApplicationRecord
  has_many :organization_users
  has_many :users, through: :organization_users

  has_many :projects
  has_many :reports

  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, uniqueness: true
end
