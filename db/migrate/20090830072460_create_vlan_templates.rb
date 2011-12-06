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

class CreateVlanTemplates < ActiveRecord::Migration
  def self.up
    create_table :vlan_templates do |t|
      t.text :notes
      t.integer :output_band_percent
      t.integer :tag

      t.references :interface_template, :polymorphic => true

      t.belongs_to :bridge_template

      t.timestamps
    end
  end

  def self.down
    drop_table :vlan_templates
  end
end
