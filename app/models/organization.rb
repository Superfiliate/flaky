class Organization < ApplicationRecord
  has_many :organization_users
  has_many :users, through: :organization_users

  has_many :projects
  has_many :reports

  validates :handle,
            presence: true,
            format: {
              with: /\A[a-z0-9\-]+\z/,
              message: "accepts only lowercase letters, numbers, and hyphens. Eg: 'my-company-name'"
            },
            uniqueness: true
end
