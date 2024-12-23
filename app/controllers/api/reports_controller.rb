module Api
  class ReportsController < ::Api::BaseController
    def simplecov
      return if uploaded_part_invalid?

      report.parts.attach(params[:part])
      expected_parts = params[:expected_parts].presence || 1
      if report.update(expected_parts:)
        report.generate_bundled_html if report.parts_complete?
        general_coverage = report.results["general_coverage"]

        markdown = <<~MARKDOWN
          [#{general_coverage} covered. Click to see the breakdown 🧮.](#{bundled_html_report_url(report)})
        MARKDOWN

        render json: { report:, markdown: }, status: :created
      else
        render json: { errors: report.errors }, status: :unprocessable_entity
      end
    end

    private

    def uploaded_part_invalid?
      part = params[:part]
      # https://api.rubyonrails.org/v6.0.3/classes/ActionDispatch/Http/UploadedFile.html#method-i-size
      message = "Missing part" unless part.present?
      message ||= "Part too big, should be under 10MB" if part && part.size > 10.megabytes
      # message ||= "Part bad format, should be 'application/zip', was '#{part.content_type}'" if part && part.content_type != "application/zip"

      if message.present?
        render json: { errors: message }, status: :unprocessable_entity
        return true
      end

      false
    end

    def report
      @report ||= begin
        current_project.with_lock do
          # Prevent race-condition on many parts of the same run being uploaded close together.
          run_identifier = params[:run_identifier].presence || Time.zone.now.iso8601
          branch = params[:branch].presence || "main"
          record = Report.find_or_create_by!(
            organization: current_project.organization,
            project: current_project,
            kind: action_name,
            run_identifier:,
            branch:,
          )
        end
      end
    end
  end
end
