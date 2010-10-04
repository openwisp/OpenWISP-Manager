class CreateAccessPoints < ActiveRecord::Migration
  def self.up
    create_table :access_points do |t|
      t.string :name, :null => false
      t.string :mac_address
      t.string :configuration_md5
      t.boolean :internal, :null => false
      t.date :activation_date
      t.string :address, :null => false
      t.string :city, :null => false
      t.string :zip, :null => false
      t.float :lat, :null => false
      t.float :lon, :null => false
      t.timestamp :committed_at
      t.text :notes

      t.belongs_to :wisp
      t.belongs_to :access_point_template

      t.timestamps
    end
    
    add_index :access_points, :mac_address
    
  end

  def self.down
    drop_table :access_points
  end
end
