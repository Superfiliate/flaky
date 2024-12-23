require "test_helper"

class Api::FilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    organization = Organization.create!(handle: "test-organization")
    @project = Project.create!(handle: "test-project", organization:)
    token = @project.reset_api_auth!

    @headers = { Authorization: "Bearer #{token}" }
    @part = fixture_file_upload(
      Rails.root.join("test/fixtures/files/user_model_coverage.zip"),
      "application/zip"
    )
  end

  test "simplecov zip upload creates and processes Report" do
    assert_equal(Report.count, 0)

    params = { part: @part }
    post simplecov_api_reports_url, params:, headers: @headers

    assert_response :created
    assert_equal(Report.count, 1)

    report = Report.last
    assert_equal(report.organization, @project.organization)
    assert_equal(report.project, @project)
    assert_equal(report.parts.count, 1)
    assert_equal(report.bundled_html.present?, true)
    assert_equal(report.formatted_coverage, "3.47%")
    assert_equal(report.branch, "main")
  end

  test "with custom run_identfier and branch" do
    Report.create!(
      organization: @project.organization,
      project: @project,
      kind: "simplecov",
      branch: "main",
      results: { general_coverage: 1.23 }
    )

    params = { part: @part, run_identifier: "custom-run", branch: "custom-branch" }
    post simplecov_api_reports_url, params:, headers: @headers

    assert_response :created
    assert_equal(response.body.include?("3.47% covered (+2.24% coverage improved)"), true)
    assert_equal(Report.count, 2)

    report = Report.last
    assert_equal(report.run_identifier, "custom-run")
    assert_equal(report.branch, "custom-branch")
  end
end
