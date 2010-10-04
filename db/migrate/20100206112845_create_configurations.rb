class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string  :key,        :null => false
      t.string  :value,      :null => false, :default => ''
      t.boolean :system_key, :null => false, :default => 0

      t.timestamps
    end
    
    add_index :configurations, :key
    
  end

  def self.down
    drop_table :configurations
  end
end
