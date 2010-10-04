class EthernetsController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point
  before_filter :load_ethernet, :except => [ :index, :new, :create ]
    
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
    allow :wisp_viewer, :of => :wisp, :to => [:show, :index]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end

  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end
  
  def load_ethernet
    @ethernet = @access_point.ethernets.find(params[:id]) 
  end

  def index
    @ethernets = @access_point.ethernets.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
