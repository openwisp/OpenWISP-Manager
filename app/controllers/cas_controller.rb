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
