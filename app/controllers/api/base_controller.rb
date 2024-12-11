module Api
  class BaseController < ApplicationController
    skip_forgery_protection
    skip_before_action :authenticate_user!
    before_action :authenticate_project!

    def current_project
      authenticate_with_http_token do |token, _options|
        Project.find_by_token(token)
      end
    end

    private

    def authenticate_project!
      head :unauthorized if current_project.blank?
    end
  end
end
