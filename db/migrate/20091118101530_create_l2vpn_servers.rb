class CreateL2vpnServers < ActiveRecord::Migration
  def self.up
    create_table :l2vpn_servers do |t|
      t.string :name
      t.integer :port, :null => false
      t.string :protocol, :null => false
      t.string :cipher, :null => false
      t.text :tls_auth
      t.text :dh
      t.text :notes
      t.string :ip
      t.integer :mtu
      t.string :mtu_disc

      t.belongs_to :server
      t.belongs_to :wisp

      t.timestamps
    end
  end

  def self.down
    drop_table :l2vpn_servers
  end
end
