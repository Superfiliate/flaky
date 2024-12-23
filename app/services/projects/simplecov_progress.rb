module Projects
  class SimplecovProgress
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def call
      # TODO: could be improved to only get the last report of each date.
      # TODO: could be improved to remove blank coverage reports at the SQL level.
      project.reports.where(branch: "main").order(:created_at).map do |report|
        next if report.general_coverage.blank?

        [ report.created_at, report.general_coverage ]
      end.compact
    end
  end
end
