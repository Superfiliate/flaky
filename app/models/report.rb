class Report < ApplicationRecord
  belongs_to :organization
  belongs_to :project

  has_one_attached :bundled_html
end
