class EthernetsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
  before_filter :load_ethernet, :except => [ :index, :new, :create ]
    
  access_control do
    default :deny

    actions :index do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end
  end

  def index
    @ethernets = @access_point.ethernets.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  private
  
  def load_ethernet
    @ethernet = @access_point.ethernets.find(params[:id])
  end
end
