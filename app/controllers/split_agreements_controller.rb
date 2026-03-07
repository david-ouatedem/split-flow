class SplitAgreementsController < ApplicationController
  include ProjectAuthorization

  before_action :authenticate_user!, except: [:verify]
  before_action :set_project, except: [:verify]
  before_action :authorize_project_access!, except: [:verify]
  before_action :authorize_project_owner!, only: [:new, :create, :edit, :update, :propose]
  before_action :set_agreement, only: [:show, :edit, :update, :propose, :export_pdf]
  before_action :prevent_locked_changes, only: [:edit, :update]

  def show
    @entries = @agreement.split_entries.includes(:user).order(:created_at)
  end

  def new
    if @project.split_agreement.present?
      redirect_to project_split_agreement_path(@project), alert: "Split agreement already exists."
      return
    end

    @agreement = @project.build_split_agreement
    build_entries_for_participants
  end

  def create
    if @project.split_agreement.present?
      redirect_to project_split_agreement_path(@project), alert: "Split agreement already exists."
      return
    end

    @agreement = @project.build_split_agreement

    if build_and_save_entries
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_path(@project), notice: "Split agreement created." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @entries = @agreement.split_entries.includes(:user).order(:created_at)
  end

  def update
    if update_entries_from_params
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_split_agreement_path(@project), notice: "Split agreement updated." }
      end
    else
      @entries = @agreement.split_entries.includes(:user).order(:created_at)
      render :edit, status: :unprocessable_entity
    end
  end

  def propose
    unless @agreement.draft?
      redirect_to project_split_agreement_path(@project), alert: "Agreement is already proposed."
      return
    end

    unless @agreement.valid_percentages?
      redirect_to edit_project_split_agreement_path(@project),
        alert: "Cannot propose. Total percentage must equal 100% (currently #{@agreement.total_percentage.round(2)}%)."
      return
    end

    if @agreement.propose!
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_split_agreement_path(@project), notice: "Split agreement proposed! Awaiting collaborator approvals." }
      end
    else
      redirect_to project_split_agreement_path(@project), alert: "Failed to propose agreement."
    end
  end

  def export_pdf
    unless @agreement.locked?
      redirect_to project_split_agreement_path(@project), alert: "Can only export locked agreements."
      return
    end

    pdf = SplitAgreementPdfGenerator.new(@agreement).generate
    filename = "#{@project.title.parameterize}-split-agreement-#{@agreement.locked_at.to_date}.pdf"

    send_data pdf,
      filename: filename,
      type: 'application/pdf',
      disposition: 'attachment'
  end

  def verify
    @agreement = SplitAgreement.find_by!(verification_token: params[:verification_token])
    @project = @agreement.project
    @entries = @agreement.split_entries.includes(:user).order(percentage: :desc)

    render layout: 'public_verification'
  rescue ActiveRecord::RecordNotFound
    render 'verify_not_found', status: :not_found, layout: 'public_verification'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_agreement
    @agreement = @project.split_agreement
    redirect_to new_project_split_agreement_path(@project), alert: "No split agreement found." unless @agreement
  end

  def prevent_locked_changes
    if @agreement&.locked?
      redirect_to project_split_agreement_path(@project), alert: "Cannot modify locked agreement."
    end
  end

  def build_entries_for_participants
    @project.all_participants.each do |participant|
      @agreement.split_entries.build(user: participant, percentage: 0)
    end
  end

  def build_and_save_entries
    return false unless @agreement.save

    params[:split_entries]&.each do |user_id, attributes|
      next if attributes[:percentage].blank?

      @agreement.split_entries.create!(
        user_id: user_id,
        percentage: attributes[:percentage]
      )
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    @agreement.errors.add(:base, e.message)
    false
  end

  def update_entries_from_params
    ActiveRecord::Base.transaction do
      params[:split_entries]&.each do |entry_id, attributes|
        entry = @agreement.split_entries.find(entry_id)
        entry.update!(percentage: attributes[:percentage]) if attributes[:percentage].present?
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    @agreement.errors.add(:base, e.message)
    false
  end
end
