class CreateL2vpnTemplates < ActiveRecord::Migration
  def self.up
    create_table :l2vpn_templates do |t|
      t.text :notes

      t.belongs_to :access_point_template
      t.belongs_to :l2vpn_server

      t.timestamps
    end
  end

  def self.down
    drop_table :l2vpn_templates
  end
end
