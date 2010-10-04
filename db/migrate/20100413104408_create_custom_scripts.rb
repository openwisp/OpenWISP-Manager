class CreateCustomScripts < ActiveRecord::Migration
  def self.up
    create_table :custom_scripts do |t|
      t.string :name
      t.text :body
      t.text :notes
      t.string :cron_minute
      t.string :cron_hour
      t.string :cron_day
      t.string :cron_month
      t.string :cron_dayweek
      
      t.belongs_to :access_point
      
      t.timestamps
    end
  end

  def self.down
    drop_table :custom_scripts
  end
end
