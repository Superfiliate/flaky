class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = ::Users::OmniauthUpserter.new(request.env["omniauth.auth"]).call
    sign_in_and_redirect(@user)
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || organizations_path
  end
end
