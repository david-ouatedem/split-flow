class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :display_name, :bio, :avatar, :role,
      skills: []
    ).tap do |whitelisted|
      if params[:user][:portfolio_urls].present?
        whitelisted[:portfolio_urls] = params[:user][:portfolio_urls]
          .to_unsafe_h
          .select { |_, v| v.present? }
      end
    end
  end
end
