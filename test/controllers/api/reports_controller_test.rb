require 'test_helper'

class Api::FilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @organization = Organization.create!(handle: "test-organization")
    @project = Project.create!(handle: "test-project", organization: @organization)
    @token = @project.reset_api_auth!
  end

  def teardown
    Report.all.each(&:destroy)
    Project.all.each(&:destroy)
    Organization.all.each(&:destroy)
    ActiveStorage::Blob.all.each(&:purge)
  end

  test "simplecov zip upload creates and processes Report" do
    headers = { Authorization: "Bearer #{@token}" }
    uploaded_file = fixture_file_upload(
      Rails.root.join('test/fixtures/files/user_model_coverage.zip'),
      'application/zip'
    )

    assert_equal(Report.count, 0)

    post simplecov_api_reports_url, params: { part: uploaded_file }, headers: headers

    assert_response :created
    assert_equal(Report.count, 1)
    assert_equal(Report.first.parts.count, 1)
    assert_equal(Report.first.bundled_html.present?, true)
    assert_equal(Report.first.results["general_coverage"], 3.47)
  end
end
