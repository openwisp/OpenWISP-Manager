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

class AddInputBandToShapeables < ActiveRecord::Migration
  def self.up
    add_column :ethernet_templates, :input_band, :integer
    add_column :ethernets, :input_band, :integer
    add_column :radio_templates, :input_band, :integer
    add_column :radios, :input_band, :integer
    add_column :tap_templates, :input_band, :integer
    add_column :taps, :input_band, :integer

    add_column :vlan_templates, :input_band_percent, :integer
    add_column :vlans, :input_band_percent, :integer
    add_column :vap_templates, :input_band_percent, :integer
    add_column :vaps, :input_band_percent, :integer
  end

  def self.down
    remove_column :ethernet_templates, :input_band
    remove_column :ethernets, :input_band
    remove_column :radio_templates, :input_band
    remove_column :radios, :input_band
    remove_column :tap_templates, :input_band
    remove_column :taps, :input_band

    remove_column :vlan_templates, :input_band_percent
    remove_column :vlans, :input_band_percent
    remove_column :vap_templates, :input_band_percent
    remove_column :vaps, :input_band_percent
  end
end
