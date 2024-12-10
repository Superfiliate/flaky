class Report < ApplicationRecord
  KINDS = %w[simplecov].freeze

  enum :kind, KINDS.index_with(&:to_s)

  belongs_to :organization
  belongs_to :project

  has_one_attached :bundled_html

  validates :name, :kind, presence: true
end
