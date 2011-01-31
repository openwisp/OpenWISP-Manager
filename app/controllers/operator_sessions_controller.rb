class OperatorSessionsController < ApplicationController
  before_filter :require_no_operator, :only => [:new, :create]
  before_filter :require_operator, :only => :destroy

  def new
    @operator_session = OperatorSession.new
  end

  def create
    @operator_session = OperatorSession.new(params[:operator_session])
    if @operator_session.save
      flash[:notice] = t(:Login_successful)

      redirect_to home_path_for(@operator_session.operator)
    else
      render :action => :new
    end
  end

  def destroy
    current_operator_session.destroy
    flash[:notice] = t(:Logout_successful)
    redirect_back_or_default new_login_url
  end
end
