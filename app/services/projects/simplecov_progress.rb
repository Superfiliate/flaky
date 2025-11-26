module Projects
  class SimplecovProgress
    attr_reader :project, :since

    def initialize(project, since: nil)
      @project = project
      @since = since
    end

    def call
      # TODO: could be improved to only get the last report of each date.
      # TODO: could be improved to remove blank coverage reports at the SQL level.
      scope = project
        .reports
        .simplecov
        .where(branch: "main")
        .where("JSON_EXTRACT(results, '$.general_coverage') IS NOT NULL")

      scope = scope.where("created_at >= ?", since) if since.present?

      scope
        .group("DATE(created_at)")
        .order(:created_at)
        .map { |report| [ report.created_at, report.general_coverage ] }
        .compact
    end
  end
end
