class Report < ApplicationRecord
  KINDS = %w[simplecov].freeze

  enum :kind, KINDS.index_with(&:to_s)

  belongs_to :organization
  belongs_to :project

  has_one_attached :bundled_html
  has_many_attached :parts

  before_validation :prefill_defaults

  validates :name, :kind, presence: true
  # validates :expected_parts, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 50 }
  validate :validate_too_many_parts

  scope :parts_failed, -> { where(expected_parts: 0) }
  # scope :incomplete, -> { where(expected_parts:) }
  # scope :complete, -> { where(expected_parts:) }

  def pending?
    expected_parts == 0 || parts.count < expected_parts || bundled_html.blank?
  end

  def parts_complete?
    expected_parts > 0 && parts.count == expected_parts
  end

  def generate_bundled_html
    return unless parts_complete?

    simplecov_generate_bundled_html if simplecov?
    simplecov_generate_results if simplecov?
  end

  def simplecov_generate_bundled_html
    update(bundled_html: parts.first.blob)
  end

  def simplecov_generate_results
    nil if bundled_html.blank?

    bundled_html.open do |tempzip|
      Zip::File.open(tempzip.path) do |zip_entries|
        zip_entries.each do |zip_entry|
          raise "File too large when extracted" if zip_entry.size > 100.megabytes
          next unless zip_entry.name.include?(".last_run.json")

          content = zip_entry.get_input_stream.read
          json = JSON.parse(content)
          general_coverage = json["result"]["line"]

          self.update!(results: self[:results].deep_merge(general_coverage:))
        end
      end
    end
  end

  def general_coverage
    results["general_coverage"]
  end

  def formatted_coverage
    return if general_coverage.blank?

    "#{general_coverage}%"
  end

  private

  def prefill_defaults
    self[:name] = name.presence || "#{kind} - #{(created_at || Time.zone.now).iso8601}"
    self[:expected_parts] = expected_parts.presence || 0
  end

  def validate_too_many_parts
    return if parts.count <= expected_parts

    errors.add(:parts, "Too many parts")
  end
end
