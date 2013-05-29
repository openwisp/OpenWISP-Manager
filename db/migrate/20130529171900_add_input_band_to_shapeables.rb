# This file is part of the OpenWISP Manager
#
# Copyright (C) 2012 OpenWISP.org
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

class AddInputbandToShapeables < ActiveRecord::Migration
  def self.up
    add_colum :ethernet_template, :input_band, :integer
    add_colum :ethernet, :input_band, :integer
    add_colum :radio_template, :input_band, :integer
    add_colum :radio, :input_band, :integer
    add_colum :tap_template, :input_band, :integer
    add_colum :tap, :input_band, :integer

    add_colum :vlan_template, :input_band_percent, :integer
    add_colum :vlan, :input_band_percent, :integer
    add_colum :vap_template, :input_band_percent, :integer
    add_colum :vap, :input_band_percent, :integer
  end

  def self.down
    remove_colum :ethernet_template, :input_band
    remove_colum :ethernet, :input_band
    remove_colum :radio_template, :input_band
    remove_colum :radio, :input_band
    remove_colum :tap_template, :input_band
    remove_colum :tap, :input_band

    remove_colum :vlan_template, :input_band_percent
    remove_colum :vlan, :input_band_percent
    remove_colum :vap_template, :input_band_percent
    remove_colum :vap, :input_band_percent
  end
end
