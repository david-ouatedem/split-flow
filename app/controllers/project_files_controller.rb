class ProjectFilesController < ApplicationController
  include ProjectAuthorization

  before_action :authenticate_user!
  before_action :set_project
  before_action :authorize_project_access!
  before_action :set_project_file, only: [ :destroy ]

  # POST /projects/:project_id/files
  def create
    @project_file = @project.project_files.build(project_file_params)
    @project_file.uploader = current_user

    if @project_file.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("project-files-list", partial: "project_files/file", locals: { project_file: @project_file }),
            turbo_stream.update("file-upload-form", partial: "project_files/upload_form", locals: { project: @project, project_file: @project.project_files.build })
          ]
        end
        format.html { redirect_to project_path(@project), notice: "File uploaded successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("file-upload-form",
            partial: "project_files/upload_form",
            locals: { project: @project, project_file: @project_file })
        end
        format.html { redirect_to project_path(@project), alert: @project_file.errors.full_messages.join(", ") }
      end
    end
  end

  # DELETE /projects/:project_id/files/:id
  def destroy
    if @project_file.uploader == current_user || @project.owned_by?(current_user)
      @project_file.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("project_file_#{@project_file.id}") }
        format.html { redirect_to project_path(@project), notice: "File deleted successfully." }
      end
    else
      redirect_to project_path(@project), alert: "You can only delete your own files."
    end
  end

  # GET /projects/:project_id/files/download_all
  def download_all
    require "zip"

    files = @project.project_files.includes(:uploader)

    if files.empty?
      redirect_to project_path(@project), alert: "No files to download."
      return
    end

    zip_filename = "#{@project.title.parameterize}-files-#{Time.current.to_i}.zip"

    # Stream the ZIP file
    send_data generate_zip(files), filename: zip_filename, type: "application/zip"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_file
    @project_file = @project.project_files.find(params[:id])
  end

  def project_file_params
    params.require(:project_file).permit(:file, :label, :name)
  end

  def generate_zip(files)
    require "zip"
    require "stringio"

    zip_stream = Zip::OutputStream.write_buffer do |zip|
      files.each do |project_file|
        next unless project_file.file.attached?

        # Organize files by label
        folder_name = project_file.label.parameterize
        filename = "#{project_file.name}"

        zip.put_next_entry("#{folder_name}/#{filename}")
        zip.write project_file.file.download
      end
    end

    zip_stream.rewind
    zip_stream.sysread
  end
end
