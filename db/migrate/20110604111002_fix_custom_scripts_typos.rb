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
