class SplitEntriesController < ApplicationController
  include ProjectAuthorization

  before_action :authenticate_user!
  before_action :set_project
  before_action :set_split_agreement
  before_action :set_split_entry
  before_action :authorize_can_approve
  before_action :authorize_agreement_pending

  def approve
    if @entry.approve!(current_user)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to project_split_agreement_path(@project),
            notice: "You have approved your split percentage of #{@entry.percentage}%."
        end
      end
    else
      redirect_to project_split_agreement_path(@project), alert: "Failed to approve entry."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_split_agreement
    @agreement = @project.split_agreement
    unless @agreement
      redirect_to project_path(@project), alert: "No split agreement found."
    end
  end

  def set_split_entry
    @entry = @agreement.split_entries.find(params[:id])
  end

  def authorize_can_approve
    unless @entry.can_be_approved_by?(current_user)
      redirect_to project_split_agreement_path(@project),
        alert: "You can only approve your own split entry."
    end
  end

  def authorize_agreement_pending
    unless @agreement.pending?
      redirect_to project_split_agreement_path(@project),
        alert: "Can only approve pending agreements."
    end
  end
end
