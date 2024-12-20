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

  def reports_coverage_progress
    reports.map do |report|
      next if report.general_coverage.blank?

      [ report.created_at, report.general_coverage ]
    end.compact
  end
end
