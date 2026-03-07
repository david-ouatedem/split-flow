class CollaborationsController < ApplicationController
  include ProjectAuthorization

  before_action :authenticate_user!
  before_action :set_project, only: [ :create, :destroy ]
  before_action :authorize_project_owner!, only: [ :create, :destroy ]
  before_action :set_collaboration, only: [ :accept, :decline ]

  def create
    email = collaboration_params[:email]&.downcase&.strip
    user = User.find_by(email: email)
    newly_invited = false

    if user.nil?
      # Create stub user via devise_invitable
      user = User.invite!({ email: email }, current_user) do |u|
        u.skip_invitation = true
      end
      newly_invited = true

      unless user.persisted?
        redirect_to @project, alert: "Could not send invitation: #{user.errors.full_messages.to_sentence}"
        return
      end
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
      send_invitation_email(user, newly_invited)

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

  def send_invitation_email(user, newly_invited)
    # Only send email to users who haven't registered yet
    return if user.invitation_accepted?
    return unless newly_invited || user.created_by_invite?

    # Re-generate invitation token for pre-existing stub users
    unless newly_invited
      user.invite!(current_user) do |u|
        u.skip_invitation = true
      end
    end

    CollaborationInvitationMailer.invite_to_project(
      user.id, @project.id, current_user.id, user.raw_invitation_token
    ).deliver_later
  end
end
