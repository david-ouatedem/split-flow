module Users
  class InvitationsController < Devise::InvitationsController
    before_action :configure_permitted_parameters

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [ :display_name ])
    end

    def after_accept_path_for(resource)
      pending_collaboration = resource.collaborations.pending.order(:created_at).first
      if pending_collaboration
        project_path(pending_collaboration.project)
      else
        root_path
      end
    end
  end
end
