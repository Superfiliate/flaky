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
    with_folder_with_unzipped_parts do |tempdir|
      # `File::FNM_DOTMATCH` to also include hidden files
      resultset_json_filepaths = Dir.glob(File.join(tempdir, "**", "*resultset.json"), File::FNM_DOTMATCH)

      merged_folder_path = File.join(tempdir, "SIMPLECOV-MERGED-COVERAGE")
      SimpleCov.collate(resultset_json_filepaths, "rails") do
        coverage_dir(merged_folder_path)
      end

      merged_zip_path = "#{merged_folder_path}.zip"
      Files::ZipFileGenerator.new(merged_folder_path, merged_zip_path).call

      bundled_html.attach(io: File.open(merged_zip_path), filename: "bundled_html.zip", content_type: "application/zip")
    end
  end

  def simplecov_generate_results
    nil if bundled_html.blank?

    # TODO: fill the Report#results with some overall details too
  end

  private

  def prefill_defaults
    self[:name] = name.presence || "#{kind} - #{(created_at || Time.zone.now).iso8601}"
    self[:expected_parts] = expected_parts.presence || 0
  end

  def with_folder_with_unzipped_parts
    Dir.mktmpdir do |tempdir|
      parts.each do |part|
        part.open do |tempzip|
          Zip::File.open(tempzip.path) do |zip_entries|
            zip_entries.each do |zip_entry|
              raise "File too large when extracted" if zip_entry.size > 10.megabytes

              file_path = File.join(tempdir, part.id.to_s, zip_entry.name)
              folder_path = file_path.reverse.split("/", 2).last.reverse
              FileUtils.mkdir_p(folder_path) # Create the nested folders
              zip_entry.extract(file_path)
            end
          end
        end
      end

      yield tempdir
    end
  end

  def validate_too_many_parts
    return if parts.count <= expected_parts

    errors.add(:parts, "Too many parts")
  end
end
