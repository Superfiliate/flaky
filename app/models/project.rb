class Project < ApplicationRecord
  belongs_to :organization
  has_many :projects

  def self.find_by_token(token)
    Project.find_by(api_auth_digest: Digest::SHA512.hexdigest(token))
  end

  def reset_api_auth!
    token = "sffp1_" + SecureRandom.hex(64)
    update!(api_auth_digest: Digest::SHA512.hexdigest(token))
    token
  end
end
