module Api
  class ReportsController < ::Api::BaseController
    def simplecov
      report = Report.new(
        organization: current_project.organization,
        project: current_project,
        kind: :simplecov,
        name: "SimpleCov - #{Time.zone.now.iso8601}",
        bundled_html: params[:bundled_html]
      )

      if report.save
        # TODO: Include the general % coverage from the file too.
        markdown = <<~MARKDOWN
          [See the full coverage report](#{bundled_html_report_url(report)})
        MARKDOWN

        render json: { report:, markdown: }, status: :created
      else
        render json: { errors: report.errors }, status: :unprocessable_entity
      end
    end
  end
end
