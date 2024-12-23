module Projects
  class SimplecovProgress
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def call
      # TODO: could be improved to only get the last report of each date.
      # TODO: could be improved to remove blank coverage reports at the SQL level.
      project
        .reports
        .simplecov
        .where(branch: "main")
        .where("JSON_EXTRACT(results, '$.general_coverage') IS NOT NULL")
        .group("DATE(created_at)")
        .order(:created_at)
        .map { |report| [ report.created_at, report.general_coverage ] }
        .compact
    end
  end
end
