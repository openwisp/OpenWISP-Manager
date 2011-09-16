# This file is part of the OpenWISP Manager
#
# Copyright (C) 2010 CASPUR (wifi@caspur.it)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class OperatorSessionsController < ApplicationController
  skip_before_filter :require_operator, :only => [:new, :create]
  before_filter :require_no_operator, :only => [:new, :create]

  def new
    @operator_session = OperatorSession.new
  end

  def create
    @operator_session = OperatorSession.new(params[:operator_session])
    if @operator_session.save
      flash[:notice] = t(:Login_successful)

      redirect_to welcome_operator_path(@operator_session.operator)
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
