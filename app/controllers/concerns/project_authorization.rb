module ProjectAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_project_access!
    unless @project.accessible_by?(current_user)
      redirect_to projects_path, alert: "You don't have access to this project."
    end
  end

  def authorize_project_owner!
    unless @project.owned_by?(current_user)
      redirect_to project_path(@project), alert: "Only the project owner can perform this action."
    end
  end
end
