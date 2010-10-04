require 'yaml'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "main"

  before_filter :configure_gmap_key

  helper_method :current_operator_session, :current_operator
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :password, :password_confirmation
  
  private
    def configure_gmap_key
      #Read the API key config for the current ENV
      unless File.exist?(RAILS_ROOT + '/config/gmaps_api_key.yml')
        raise GMapsAPIKeyConfigFileNotFoundException.new("File RAILS_ROOT/config/gmaps_api_key.yml not found")
      else
        env = ENV['RAILS_ENV'] || RAILS_ENV
        gak = YAML::load_file(RAILS_ROOT + '/config/gmaps_api_key.yml')[env]
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
    
    def require_operator
      unless current_operator
        store_location
        flash[:notice] = t(:You_must_be_logged_in_to_access_this_page)
        redirect_to new_operator_session_url
        return false
      end
    end

    def require_no_operator
      if current_operator
        store_location
        flash[:notice] = t(:You_must_be_logged_out_to_access_this_page)
        if current_operator.has_role? "admin"
          redirect_to wisps_url
        else
          redirect_to wisp_url(current_operator.wisp)
        end
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

end
