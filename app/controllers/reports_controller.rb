require "zip"

class ReportsController < ApplicationController
  MAX_SIZE_RESPONSE = 100 * 1024**2 # 100MiB

  protect_from_forgery except: %i[bundled_html]

  def bundled_html
    # TODO: Rescue and render some errors
    @report = reports.find(params[:id])
    return if @report.pending?

    if lookup_path.blank?
      if bundled_html_list_of_files.find { |item| item[:name] == "index.html" }.present?
        redirect_to "#{request.original_url}/index.html"
      end

      return
    end

    extracted_file = extract_file
    if extract_file.nil?
      flash.now[:danger] = "File not found! '#{lookup_path}'"
      return bundled_html_list_of_files
    end

    # https://stackoverflow.com/questions/9233021/returning-files-from-rails
    # https://apidock.com/rails/ActionController/DataStreaming/send_data
    send_data(
      extracted_file,
      disposition: "inline",
      filename: lookup_path.split("/").last,
      type: Marcel::MimeType.for(extracted_file)
    )
  end

  private

  # TODO: memoize
  def bundled_html_list_of_files
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
  # TODO: memoize
  # TODO: keep the tempfile around for a while, so we don't need to download it again
  def extract_file
    @report.bundled_html.open do |tempfile|
      Zip::File.open(tempfile.path) do |zip_entries|
        entry = zip_entries.glob(lookup_path).first
        return nil if entry.nil?

        raise "File too large when extracted" if entry.size > MAX_SIZE_RESPONSE
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
