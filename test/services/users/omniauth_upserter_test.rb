require "test_helper"

class Users::OmniauthUpserterTest < ActiveSupport::TestCase
  Auth = Struct.new(:provider, :uid, :info)
  AuthInfo = Struct.new(:nickname, :email)

  def setup
    @auth = Auth.new(
      provider: "github",
      uid: "12345",
      info: AuthInfo.new(
        nickname: "testuser",
        email: "testuser@example.com"
      )
    )

    @organization = Organization.create!(
      handle: "test-organization",
      user_queue: [ "testuser" ]
    )
  end

  def test_creates_new_user_if_not_existing
    assert_difference "User.count", 1 do
      @returned_user = ::Users::OmniauthUpserter.new(@auth).call
    end

    assert_equal "github", @returned_user.provider
    assert_equal "12345", @returned_user.uid
    assert_equal "testuser", @returned_user.handle
    assert_equal "testuser@example.com", @returned_user.email
  end

  def test_finds_existing_user_if_already_exists
    existing_user = User.create!(
      provider: "github",
      uid: "12345",
      handle: "testuser",
      email: "testuser@example.com",
      password: "securepassword"
    )

    assert_no_difference "User.count" do
      @returned_user = ::Users::OmniauthUpserter.new(@auth).call
    end

    assert_equal existing_user.id, @returned_user.id
  end

  def test_enrolls_user_from_organization_queues
    @returned_user = ::Users::OmniauthUpserter.new(@auth).call

    assert @organization.reload.user_queue.exclude?(@returned_user.handle)
    assert OrganizationUser.exists?(organization: @organization, user: @returned_user)
  end

  def test_does_not_fail_when_handle_not_in_queue
    @organization.update!(user_queue: [])

    assert_nothing_raised do
      @returned_user = ::Users::OmniauthUpserter.new(@auth).call
    end

    assert @returned_user.is_a?(User)
  end
end
