class OrganizationsController < ApplicationController
  def index
    @organizations = organizations.all
  end

  def create; end

  def show
    @organization = organizations.find(params[:id])
    @projects = @organization.projects
  end

  private

  def organizations
    current_user.organizations
  end
end
