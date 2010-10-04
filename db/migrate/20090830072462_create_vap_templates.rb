class CreateVapTemplates < ActiveRecord::Migration
  def self.up
    create_table :vap_templates do |t|
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

      t.belongs_to :radio_template
      
      t.belongs_to :bridge_template

      t.timestamps
    end
  end

  def self.down
    drop_table :vap_templates
  end
end
