class CreateCas < ActiveRecord::Migration
  def self.up
    create_table :cas do |t|
      t.integer :serial, :null => false
      t.string :c, :null => false
      t.string :st, :null => false
      t.string :l, :null => false
      t.string :o, :null => false
      t.string :cn, :null => false
      t.text :crl_list
      
      t.belongs_to :wisp

      t.timestamps
    end
    
  end

  def self.down
    drop_table :cas
  end
end
