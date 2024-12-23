class Project < ApplicationRecord
  belongs_to :organization
  has_many :reports

  validates :handle,
            presence: true,
            format: {
              with: /\A[a-z0-9\-]+\z/,
              message: "accepts only lowercase letters, numbers, and hyphens. Eg: 'my-github-repo'"
            },
            uniqueness: { scope: :organization }

  def self.find_by_token(token)
    Project.find_by(api_auth_digest: Digest::SHA512.hexdigest(token))
  end

  def reset_api_auth!
    token = "sffp1_" + SecureRandom.hex(64)
    update!(api_auth_digest: Digest::SHA512.hexdigest(token))
    token
  end

  def last_main_branch_general_coverage
    reports
      .simplecov
      .where(branch: "main")
      .where("JSON_EXTRACT(results, '$.general_coverage') IS NOT NULL")
      .order(:created_at)
      .last&.general_coverage || 0
  end
end
