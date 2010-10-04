class CasController < ApplicationController
  before_filter :load_wisp

  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show, :index, :new, :edit, :create, :update, :destroy]
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
    
end
