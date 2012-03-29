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

class DestroyWeeklyAndHourlyAccessPoints < ActiveRecord::Migration
  def self.up
    drop_table :weekly_monitoring_access_points
    drop_table :hourly_monitoring_access_points
  end

  def self.down
    create_table :weekly_monitoring_access_points do |t|
      t.date :date
      t.integer :percentage

      t.belongs_to :access_point

    end

    create_table :hourly_monitoring_access_points do |t|
      t.integer :hour
      t.date :date

      t.belongs_to :access_point
    end
  end
end
