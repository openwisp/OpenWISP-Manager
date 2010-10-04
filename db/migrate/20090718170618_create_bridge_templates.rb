class CreateBridgeTemplates < ActiveRecord::Migration
  def self.up
    create_table :bridge_templates do |t|
      t.string :name, :null => false
      t.text :notes

      t.string :ip_range_begin
      t.string :ip_range_end

      t.string :netmask
      t.string :gateway
      t.string :dns

      # static, dynamic, none
      t.string :addressing_mode, :null => false

      t.belongs_to :access_point_template

      t.timestamps
    end
  end

  def self.down
    drop_table :bridge_templates
  end
end
