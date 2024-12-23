require "zip"

class ReportsController < ApplicationController
  protect_from_forgery except: %i[bundled_html]

  def bundled_html
    # TODO: Rescue and render some errors
    @report = reports.find(params[:id])
    return if @report.pending?

    if lookup_path.blank?
      indexes = bundled_html_list_of_files.filter { |item| item[:name].include?("index.html") }
      index = indexes.sort_by { |item| item[:name].length }.first

      redirect_to index[:href] if index.present?
      return
    end

    extracted_file = extract_file
    if extract_file.nil?
      flash.now[:danger] = "File not found! '#{lookup_path}'"
      return bundled_html_list_of_files
    end

    # https://stackoverflow.com/questions/9233021/returning-files-from-rails
    # https://apidock.com/rails/ActionController/DataStreaming/send_data
    # type = "text/css" if lookup_path.end_with?(".css")
    # type = Marcel::MimeType.for(extracted_file)
    # type = "text/css" if lookup_path.end_with?(".css")
    # type = "text/javascript" if lookup_path.end_with?(".js")
    type = Marcel::MimeType.for(name: lookup_path)

    send_data(
      extracted_file,
      disposition: "inline",
      filename: lookup_path.split("/").last,
      **(type.present? ? { type: } : {}),
    )
  end

  private

  memoize def bundled_html_list_of_files
    @items = with_zip_entries do |entries|
      entries.map do |entry|
        without_prefix = entry.name
        # without_prefix = entry.name.split("/", 2)[1]
        # next if without_prefix.blank?

        { href: bundled_html_report_path(@report) + "/" + without_prefix, name: without_prefix }
      end.compact
    end
  end

  def lookup_path
    with_slash = request.original_url.split("bundled_html")[1] || ""
    with_slash[1..-1]
  end

  # https://edgeguides.rubyonrails.org/active_storage_overview.html#downloading-files
  # https://github.com/rubyzip/rubyzip?tab=readme-ov-file#reading-a-zip-file
  # TODO: keep the tempfile around for a while, so we don't need to download it again
  memoize def extract_file
    @report.bundled_html.open do |tempfile|
      Zip::File.open(tempfile.path) do |zip_entries|
        entry = zip_entries.glob(lookup_path).first
        return nil if entry.nil?

        raise "File too large when extracted" if entry.size > 100.megabytes
        entry.get_input_stream.read
      end
    end
  end

  def with_zip_entries
    @report.bundled_html.open do |tempfile|
      Zip::File.open(tempfile.path) do |zip_entries|
        yield zip_entries
      end
    end
  end

  def reports
    Report.where(organization: current_user.organizations)
  end
end
