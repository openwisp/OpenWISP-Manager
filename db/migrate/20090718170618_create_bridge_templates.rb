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

class CreateBridgeTemplates < ActiveRecord::Migration
  def self.up
    create_table :bridge_templates do |t|
      t.string :name, :null => false
      t.text :notes

      t.string :ip_range_begin
      t.string :ip_range_end

      t.string :netmask
      t.string :gateway
      t.string :dns

      # static, dynamic, none
      t.string :addressing_mode, :null => false

      t.belongs_to :access_point_template

      t.timestamps
    end
  end

  def self.down
    drop_table :bridge_templates
  end
end
