class CollaborationsController < ApplicationController
  include ProjectAuthorization

  before_action :authenticate_user!
  before_action :set_project, only: [ :create, :destroy ]
  before_action :authorize_project_owner!, only: [ :create, :destroy ]
  before_action :set_collaboration, only: [ :accept, :decline ]

  def create
    user = User.find_by(email: collaboration_params[:email])

    if user.nil?
      redirect_to @project, alert: "No user found with that email."
      return
    end

    if user.id == @project.owner_id
      redirect_to @project, alert: "You cannot invite yourself."
      return
    end

    @collaboration = @project.collaborations.build(
      user: user,
      role: collaboration_params[:role],
      status: :pending
    )

    if @collaboration.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @project, notice: "Invitation sent to #{user.display_name || user.email}." }
      end
    else
      redirect_to @project, alert: @collaboration.errors.full_messages.to_sentence
    end
  end

  def destroy
    @collaboration = @project.collaborations.find(params[:id])
    @collaboration.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @project, notice: "Collaborator removed." }
    end
  end

  def accept
    if @collaboration.user_id != current_user.id
      redirect_to invitations_path, alert: "Not authorized."
      return
    end

    @collaboration.accepted!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to project_path(@collaboration.project), notice: "Invitation accepted!" }
    end
  end

  def decline
    if @collaboration.user_id != current_user.id
      redirect_to invitations_path, alert: "Not authorized."
      return
    end

    @collaboration.declined!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to invitations_path, notice: "Invitation declined." }
    end
  end

  def invitations
    @pending_invitations = current_user.collaborations.pending.includes(project: :owner)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_collaboration
    @collaboration = Collaboration.find(params[:id])
  end

  def collaboration_params
    params.require(:collaboration).permit(:email, :role)
  end
end
