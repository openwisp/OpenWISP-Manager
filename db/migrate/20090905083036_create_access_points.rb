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

class CreateAccessPoints < ActiveRecord::Migration
  def self.up
    create_table :access_points do |t|
      t.string :name, :null => false
      t.string :mac_address
      t.string :configuration_md5
      t.boolean :internal, :null => false
      t.date :activation_date
      t.string :address, :null => false
      t.string :city, :null => false
      t.string :zip, :null => false
      t.float :lat, :null => false
      t.float :lon, :null => false
      t.timestamp :committed_at
      t.text :notes

      t.belongs_to :wisp
      t.belongs_to :access_point_template

      t.timestamps
    end
    
    add_index :access_points, :mac_address
    
  end

  def self.down
    drop_table :access_points
  end
end
