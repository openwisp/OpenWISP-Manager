class CreateL2vpnClients < ActiveRecord::Migration
  def self.up
    create_table :l2vpn_clients do |t|
      t.boolean :mtu_test, :default => 0
      t.text :notes
      
      t.belongs_to :access_point
      t.belongs_to :l2vpn_server

      t.belongs_to :l2vpn_template
      
      t.timestamps
    end
  end

  def self.down
    drop_table :l2vpn_clients
  end
end
