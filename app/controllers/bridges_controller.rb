# This file is part of the OpenWISP Manager
#
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

class BridgesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point

  access_control do
    default :deny

    actions :index do
      allow :wisps_viewer
      allow :access_points_viewer, :of => :wisp
    end
  end

  # GET /wisps/:wisp_id/access_points/:access_point_id/bridges
  def index
    @bridges = @access_point.bridges.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
