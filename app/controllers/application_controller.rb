class ApplicationController < ActionController::Base
  include AnalyticsHelper

  protect_from_forgery with: :exception
  before_action :set_visitor_id
  before_action :set_phone_number
  before_action :enable_intercom_launcher

  def access_denied(exception)
    redirect_to root_path, alert: exception.message
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.admin? && resource.clients.active.empty?
      admin_root_path
    else
      super
    end
  end

  private

  def enable_intercom_launcher
    IntercomRails.config.hide_default_launcher = false
  end

  # ANALYTICS

  def set_visitor_id
    session[:visitor_id] ||= SecureRandom.hex(4)
  end

  # COMMON

  def set_phone_number
    if current_user && (phone_number = current_user.department.phone_number)
      @clientcomm_phone_number ||= ::PhoneNumberParser.format_for_display(phone_number)
    else
      ''
    end
  end
end
