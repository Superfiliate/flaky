require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create!(handle: 'TestUser', email: "user1@example.com")
    @user2 = User.create!(handle: 'AnotherUser', email: "user2@example.com")
  end

  test "find_by_handle finds user case-insensitively" do
    assert_equal @user1, User.find_by_handle('testuser')
    assert_equal @user1, User.find_by_handle('TESTUSER')
    assert_equal @user2, User.find_by_handle('anotheruser')
    assert_nil User.find_by_handle('nonexistent')
  end

  def teardown
    User.destroy_all
  end
end
