class ProjectsController < ApplicationController
  def create
    @project = Project.new(create_params)

    if @project.save
      flash[:success] = "Project '#{@project.handle}' created successfully!"
      redirect_to project_path(@project)
    else
      flash[:danger] = @project.errors.full_messages.to_sentence
      redirect_back(fallback_location: organizations_path)
    end
  end

  def show
    @project = projects.find(params[:id])
    @reports = @project.reports
  end

  private

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
