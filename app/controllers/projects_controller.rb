class ProjectsController < ApplicationController
  helper_method :simplecov_progress

  def create
    @project = Project.new(create_params)

    if @project.save
      flash[:success] = "Project '#{@project.handle}' created successfully!"
      redirect_to organization_path(@project.organization)
    else
      flash[:danger] = @project.errors.full_messages.to_sentence
      redirect_back(fallback_location: organizations_path)
    end
  end

  def show
    @project = projects.find(params[:id])
    @reports = @project.reports
  end

  def update
    @project = projects.find(params[:id])
    token = @project.reset_api_auth!

    flash[:success] = "Copy this token now, it will only be available once: #{token}"
    redirect_to project_path(@project)
  end

  private

  memoize def simplecov_progress
    ::Projects::SimplecovProgress.new(@project).call
  end

  def create_params
    params
      .require(:project)
      .permit(:handle, :organization_id)
      .tap do |partial_params|
        partial_params[:handle] = partial_params[:handle]&.parameterize

        organization = current_user.organizations.find_by(id: partial_params[:organization_id])
        partial_params[:organization_id] = organization&.id
      end
  end

  def projects
    Project.where(organization: current_user.organizations)
  end
end
