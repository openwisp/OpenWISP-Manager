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

class CreateCustomScriptTemplates < ActiveRecord::Migration
  def self.up
    create_table :custom_script_templates do |t|
      t.string :name
      t.text :body
      t.text :notes
      t.string :cron_minute
      t.string :cron_hour
      t.string :cron_day
      t.string :cron_month
      t.string :cron_dayweek
      
      t.belongs_to :access_point_template
      
      t.timestamps
    end
  end

  def self.down
    drop_table :custom_script_templates
  end
end
