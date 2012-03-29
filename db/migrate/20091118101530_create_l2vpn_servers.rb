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

class CreateL2vpnServers < ActiveRecord::Migration
  def self.up
    create_table :l2vpn_servers do |t|
      t.string :name
      t.integer :port, :null => false
      t.string :protocol, :null => false
      t.string :cipher, :null => false
      t.text :tls_auth
      t.text :dh
      t.text :notes
      t.string :ip
      t.boolean :bindall, :null => false
      t.integer :mtu
      t.string :mtu_disc

      t.belongs_to :server
      t.belongs_to :wisp

      t.timestamps
    end
  end

  def self.down
    drop_table :l2vpn_servers
  end
end
