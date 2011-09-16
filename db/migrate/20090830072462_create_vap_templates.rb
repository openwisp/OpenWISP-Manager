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

class CreateVapTemplates < ActiveRecord::Migration
  def self.up
    create_table :vap_templates do |t|
      t.text :notes
      t.integer :output_band_percent
      t.string :essid
      t.string :visibility
      t.string :encryption
      t.string :key
      t.string :radius_auth_server
      t.integer :radius_auth_server_port
      t.string :radius_acct_server
      t.integer :radius_acct_server_port

      t.belongs_to :radio_template
      
      t.belongs_to :bridge_template

      t.timestamps
    end
  end

  def self.down
    drop_table :vap_templates
  end
end
