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

class FixCustomScriptsTypos < ActiveRecord::Migration
  def self.up
    rename_column :custom_script_templates, :cron_dayweek, :cron_weekday

    rename_column :custom_scripts, :cron_dayweek, :cron_weekday
  end

  def self.down
    rename_column :custom_script_templates, :cron_weekday, :cron_dayweek

    rename_column :custom_scripts, :cron_weekday, :cron_dayweek
  end
end
