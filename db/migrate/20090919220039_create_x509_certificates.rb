class CreateX509Certificates < ActiveRecord::Migration
  def self.up
    create_table :x509_certificates do |t|
      t.string :dn, :null => false
      t.text :certificate, :null => false
      t.text :key, :null => false

      t.boolean :revoked, :default => false

      t.belongs_to :ca

      t.references :certificable, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :x509_certificates
  end
end
