class ProjectsController < ApplicationController
  include ProjectAuthorization

  before_action :authenticate_user!, except: [ :show ]
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_project_access!, only: [ :show ]
  before_action :authorize_project_owner!, only: [ :edit, :update, :destroy ]

  def index
    @owned_projects = current_user.owned_projects.order(updated_at: :desc)
    @collaborating_projects = current_user.collaborated_projects
      .joins(:collaborations)
      .where(collaborations: { status: :accepted })
      .order("projects.updated_at DESC")
      .distinct
  end

  def show
    @collaborations = @project.collaborations.includes(:user)
    @accepted_collaborations = @collaborations.accepted
    @pending_collaborations = @collaborations.pending if @project.owned_by?(current_user)
    @project_files = @project.project_files.includes(:uploader, file_attachment: :blob).ordered
    @split_agreement = @project.split_agreement
  end

  def new
    @project = current_user.owned_projects.build
  end

  def create
    @project = current_user.owned_projects.build(project_params)
    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :genre, :bpm, :visibility, :status)
  end
end
