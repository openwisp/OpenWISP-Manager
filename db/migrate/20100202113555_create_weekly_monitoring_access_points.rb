class CreateWeeklyMonitoringAccessPoints < ActiveRecord::Migration
  def self.up
    create_table :weekly_monitoring_access_points do |t|
      t.date :date
      t.integer :percentage

      t.belongs_to :access_point

    end
  end

  def self.down
    drop_table :weekly_monitoring_access_points
  end
end
