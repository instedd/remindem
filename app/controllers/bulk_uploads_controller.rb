class BulkUploadsController < AuthenticatedController

  add_breadcrumb _("Reminders"), :schedules_path
  add_breadcrumb _("Bulk Upload"), :bulk_uploads_path

  before_filter :show_breadcrumb
  before_filter :authorize_feature

  def index
  end

  def upload
    @upload = BulkUpload.from_csv(params[:file], current_user)
    if @upload.valid?
      @upload.process!
      render 'upload_success'
    else
      render 'index'
    end
  end

  private

  def authorize_feature
    raise "Unauthorized" unless current_user.feature_enabled?(:bulk_upload)
  end

end
