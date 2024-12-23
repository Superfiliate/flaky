require "test_helper"

class ::Projects::SimplecovProgressTest < ActiveSupport::TestCase
  def setup
    organization = Organization.create!(handle: "test-organization")
    @project = Project.create!(handle: "test-project", organization:)

    def create_report(created_at, general_coverage)
      Report.create!(
        organization: @project.organization,
        project: @project,
        name: "name",
        kind: :simplecov,
        created_at:,
        results: { general_coverage: }
      )
    end

    create_report("2024-11-27 01:01:01", 87.7)

    create_report("2024-11-28 01:01:01", nil)

    create_report("2024-11-29 01:01:01", 88.1).update!(results: {})

    create_report("2024-11-30 01:01:01", 89.1)
    create_report("2024-11-30 02:02:02", 89.2)

    create_report("2024-12-01 01:01:01", 90.1)
    create_report("2024-12-01 02:02:02", 92)
    create_report("2024-12-01 03:03:03", 90.3)
  end

  def test_one_datapoint_per_date
    results = ::Projects::SimplecovProgress.new(@project).call

    assert_equal(results.map do |created_at, coverage|
      [ created_at.to_date.to_s, coverage ]
    end, [
      [ "2024-11-27", 87.7 ],
      [ "2024-11-30", 89.1 ],
      [ "2024-12-01", 90.1 ]
    ])
  end
end
