class CollaborationInvitationMailer < ApplicationMailer
  def invite_to_project(user_id, project_id, inviter_id, invitation_token)
    @user = User.find(user_id)
    @project = Project.find(project_id)
    @inviter = User.find(inviter_id)
    @invitation_url = accept_user_invitation_url(invitation_token: invitation_token)

    mail(
      to: @user.email,
      subject: "#{inviter_name} invited you to collaborate on \"#{@project.title}\" — SplitFlow"
    )
  end

  private

  def inviter_name
    @inviter.display_name.presence || @inviter.email
  end
end
