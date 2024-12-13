class OrganizationsController < ApplicationController
  def index
    @organizations = organizations.all
  end

  def create
    @organization = Organization.new(create_params)

    if @organization.save
      OrganizationUser.create(organization: @organization, user: current_user)

      flash[:success] = "Organization '#{@organization.handle}' created successfully!"
      redirect_to organizations_path
    else
      flash[:danger] = @organization.errors.full_messages.to_sentence
      redirect_back(fallback_location: organizations_path)
    end
  end

  def show
    @organization = organizations.find(params[:id])
    @projects = @organization.projects
    @users = @organization.users
  end

  private

  def create_params
    params
      .require(:organization)
      .permit(:handle)
      .tap do |partial_params|
        partial_params[:handle] = partial_params[:handle]&.parameterize
      end
  end

  def organizations
    current_user.organizations
  end
end
