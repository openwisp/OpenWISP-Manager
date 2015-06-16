class AddFileToAccessPoint < ActiveRecord::Migration
  def self.up
    limit = AccessPoint.attachments_limit
    (1..limit).each do |n|
      add_column :access_points, "file#{n}".to_sym, :string
    end
  end

  def self.down
    limit = AccessPoint.attachments_limit
    (1..limit).each do |n|
      remove_column :access_points, "file#{n}".to_sym
    end
  end
end
