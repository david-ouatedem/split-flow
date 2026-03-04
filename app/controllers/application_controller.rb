class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_up_path_for(resource)
    edit_profile_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :display_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :display_name, :bio, :avatar, :role, { skills: [] }
    ])
  end
end
