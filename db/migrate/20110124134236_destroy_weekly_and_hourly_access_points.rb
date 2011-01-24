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
