class RadiosController < ApplicationController
  layout nil
  
  before_filter :load_wisp
  before_filter :load_access_point

  access_control do
    default :deny

    actions :index, :show do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end

    #TODO: In order to have per-ap radio configuration
    actions :new, :create do
      allow :wisps_creator
      allow :access_points_creator, :of => :wisp
    end

    actions :edit, :update, :outdated_access_points_update do
      allow :wisps_manager
      allow :access_points_manager, :of => :wisp
    end

    actions :destroy do
      allow :wisps_destroyer
      allow :access_points_destroyer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/radios/1/edit
  def edit
    @radio = @access_point.radios.find(params[:id])
  end
  
  def update
    @radio = @access_point.radios.find(params[:id])
    respond_to do |format|
      if @radio.update_attributes(params[:radio])
        format.html { redirect_to(wisp_access_point_radios_url(@wisp, @access_point)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def index
    @radios = @access_point.radios.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
