require 'yaml'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotification::Notifiable

  before_filter :configure_gmap_key, :set_locale

  helper_method :current_operator_session, :current_operator, :home_path_for
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :password, :password_confirmation

  def set_session_locale
    session[:locale] = params[:locale]
    redirect_to request.env['HTTP_REFERER'] || :root
  end

  private

  def available_locales; AVAILABLE_LOCALES; end

  def set_locale
    I18n.locale = available_locales.include?(session[:locale]) ? session[:locale] : nil
  end

  def configure_gmap_key
    #Read the API key config for the current ENV
    api_key_file = Rails.root.join('config','gmaps_api_key.yml')
    unless File.exist?(api_key_file)
      raise GMapsAPIKeyConfigFileNotFoundException.new("File #{api_key_file.to_s} not found")
    else
      env = ENV['RAILS_ENV'] || RAILS_ENV
      gak = YAML::load_file(api_key_file)[env]
    end

    if gak.is_a?(Hash)
      Geokit::Geocoders::google = gak[request.env['SERVER_NAME']]
    else
      #Only one possible key: take it and ignore the :host option if it is there
      Geokit::Geocoders::google = gak
    end
  end

  def current_operator_session
    return @current_operator_session if defined?(@current_operator_session)
    @current_operator_session = OperatorSession.find
  end

  def current_operator
    return @current_operator if defined?(@current_operator)
    @current_operator = current_operator_session && current_operator_session.record
  end

  def home_path_for(operator)
    welcome_operator_path(operator)
  end

  def require_operator
    unless current_operator
      store_location
      flash[:notice] = t(:You_must_be_logged_in_to_access_this_page)
      redirect_to new_operator_session_url
      false
    end
  end

  def require_no_operator
    if current_operator
      store_location
      flash[:notice] = t(:You_must_be_logged_out_to_access_this_page)
      if current_operator.wisp
        redirect_to wisp_url(current_operator.wisp)
      else
        redirect_to wisps_url
      end
      false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  ## Default (most commonly used in controllers) instance variables loaders ##
  def load_wisps
    @wisps = Wisp.all
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end

  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:access_point_template_id])
  end

  def load_server
    @server = Server.find(params[:server_id])
  end

  exception_data :load_additional_exception_data
  def load_additional_exception_data
    { :authlogic_operator => (current_operator rescue nil) }
  end
end
