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
        render json: { report: }
      else
        render json: { errors: report.errors }, status: :unprocessable_entity
      end
    end
  end
end
