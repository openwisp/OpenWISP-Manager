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

class AddDriverSupportToRadios < ActiveRecord::Migration
  def self.up
    remove_column :radio_templates, :name
    add_column :radio_templates, :driver, :string, :null => false, :default => 'madwifi-ng'
    add_column :radio_templates, :driver_slot, :integer, :null => false, :default => 0

    remove_column :radios, :name
    add_column :radios, :driver, :string #, :null => true, :default => :nil
    add_column :radios, :driver_slot, :integer  #, :null => true, :default => :nil
  end

  def self.down
    add_column :radio_templates, :name, :string, :default => 'wifi0'
    remove_column :radio_templates, :driver
    remove_column :radio_templates, :driver_slot

    add_column :radios, :name, :string
    remove_column :radios, :driver
    remove_column :radios, :driver_slot
  end
end
