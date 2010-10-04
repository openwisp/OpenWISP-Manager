class CreateVaps < ActiveRecord::Migration
  def self.up
    create_table :vaps do |t|
      t.text :notes
      t.integer :output_band_percent
      t.string :essid
      t.string :visibility
      t.string :encryption
      t.string :key
      t.string :radius_auth_server
      t.integer :radius_auth_server_port
      t.string :radius_acct_server
      t.integer :radius_acct_server_port

      t.belongs_to :radio

      t.belongs_to :bridge

      t.belongs_to :vap_template

      t.timestamps
    end
  end

  def self.down
    drop_table :vaps
  end
end
