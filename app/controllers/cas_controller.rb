class CasController < ApplicationController
  before_filter :load_wisp

  access_control do
    default :deny

    action :show do
      allow :wisps_viewer
      allow :wisp_viewer, :of => :wisp
    end

    action :crl do
      allow :wisps_manager
      allow :wisp_manager, :of => :wisp
    end
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  
  # GET /wisps/:wisp_id/ca
  def show
    @ca = @wisp.ca

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def crl
    list = @wisp.ca.crl_list ? @wisp.ca.crl_list : ''
    send_data list
  end
end
