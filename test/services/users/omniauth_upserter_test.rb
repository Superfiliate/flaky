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
      ::Users::OmniauthUpserter.new(@auth).call
    end

    user = User.find_by(uid: @auth.uid)
    assert_equal "github", user.provider
    assert_equal "12345", user.uid
    assert_equal "testuser", user.handle
    assert_equal "testuser@example.com", user.email
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
      ::Users::OmniauthUpserter.new(@auth).call
    end

    user = User.find_by(uid: @auth.uid)
    assert_equal existing_user.id, user.id
  end

  def test_enrolls_user_from_organization_queues
    ::Users::OmniauthUpserter.new(@auth).call
    user = User.find_by(uid: @auth.uid)

    assert @organization.reload.user_queue.exclude?(user.handle)
    assert OrganizationUser.exists?(organization: @organization, user: user)
  end

  def test_does_not_fail_when_handle_not_in_queue
    @organization.update!(user_queue: [])

    assert_nothing_raised do
      ::Users::OmniauthUpserter.new(@auth).call
    end
  end
end
