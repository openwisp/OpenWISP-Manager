class AddDriverSupportToRadios < ActiveRecord::Migration
  def self.up
    remove_column :radio_templates, :name
    add_column :radio_templates, :driver, :string, :null => false, :default => 'madwifi-ng'
    add_column :radio_templates, :driver_slot, :integer, :null => false, :default => 0

    remove_column :radios, :name
    add_column :radios, :driver, :string #, :null => true, :default => :nil
    add_column :radios, :driver_slot, :integer  #, :null => true, :default => :nil
  end

  def self.down
    add_column :radio_templates, :name, :string, :default => 'wifi0'
    remove_column :radio_templates, :driver
    remove_column :radio_templates, :driver_slot

    add_column :radios, :name, :string
    remove_column :radios, :driver
    remove_column :radios, :driver_slot
  end
end
