class OrganizationUsersController < ApplicationController
  def create
    @organization_user = OrganizationUser.find_or_initialize_by(create_params)

    if @organization_user.save
      flash[:success] = "User invited successfully!"
      redirect_to organization_path(@organization_user.organization)
    else
      flash[:danger] = @organization_user.errors.full_messages.to_sentence
      redirect_back(fallback_location: organizations_path)
    end
  end

  private

  def create_params
    params
      .require(:organization_user)
      .permit(:user_handle, :organization_id)
      .tap do |partial_params|
        partial_params[:user] = User.find_by_handle(partial_params.delete(:user_handle))

        organization = current_user.organizations.find_by(id: partial_params[:organization_id])
        partial_params[:organization_id] = organization&.id
      end
  end

  def projects
    Project.where(organization: current_user.organizations)
  end
end
