class CreateHourlyMonitoringAccessPoints < ActiveRecord::Migration
  def self.up
		create_table :hourly_monitoring_access_points do |t|
			t.integer :hour
			t.date :date
      
      t.belongs_to :access_point
    end
  end

  def self.down
		drop_table :hourly_monitoring_access_points
  end
end
