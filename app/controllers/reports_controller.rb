require "zip"

class ReportsController < ApplicationController
  MAX_SIZE_RESPONSE = 100 * 1024**2 # 100MiB

  protect_from_forgery except: %i[bundled_html]

  def bundled_html
    return redirect_to "#{request.original_url}/index.html" if bundled_path.blank?

    # TODO: Need to check the authorization...
    # TODO: Rescue and render some errors
    @report = Report.find(params[:id])

    # render json: { original_url: request.original_url, bundled_path:, report: }

    # https://stackoverflow.com/questions/9233021/returning-files-from-rails
    # https://apidock.com/rails/ActionController/DataStreaming/send_data
    send_data(
      extract_file,
      disposition: "inline",
      filename: bundled_path.split("/").last,
      # :type => "mime/type"
    )
  end

  private

  def bundled_path
    with_slash = request.original_url.split("bundled_html")[1] || ""
    with_slash[1..-1]
  end

  # https://edgeguides.rubyonrails.org/active_storage_overview.html#downloading-files
  # https://github.com/rubyzip/rubyzip?tab=readme-ov-file#reading-a-zip-file
  def extract_file
    @report.bundled_html.open do |tempfile|
      Zip::File.open(tempfile.path) do |zip_entries|
        entry = zip_entries.glob("*/#{bundled_path}").first
        return nil if entry.nil?

        raise "File too large when extracted" if entry.size > MAX_SIZE_RESPONSE
        entry.get_input_stream.read
      end
    end
  end
end
