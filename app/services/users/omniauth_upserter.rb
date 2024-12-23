module Users
  class OmniauthUpserter
    attr_reader :auth, :user

    # Called by the `omniauth_callbacks_controller.rb`
    def initialize(auth)
      @auth = auth
    end

    def call
      @user = ::User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |new_user|
        new_user.provider = auth.provider
        new_user.uid = auth.uid

        new_user.handle = auth.info.nickname
        new_user.email = auth.info.email
        new_user.password = SecureRandom.hex(20)
      end

      enroll_from_organization_queues
    end

    private

    def enroll_from_organization_queues
      # https://www.sqlite.org/json1.html#examples_using_json_each_and_json_tree_
      Organization
        .joins("JOIN json_each(user_queue) AS user_queued_handle")
        .where("user_queued_handle.value = :handle", handle: user.handle)
        .uniq
        .each do |organization|
          organization.with_lock do
            next unless organization.user_queue.include?(user.handle)

            OrganizationUser.create!(organization:, user:)
            organization.user_queue.delete(user.handle)
            organization.save!
          end
        end
    end
  end
end
