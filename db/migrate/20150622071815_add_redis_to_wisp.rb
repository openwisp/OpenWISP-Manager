class AddRedisToWisp < ActiveRecord::Migration
  def self.up
      add_column :wisps, :redis_server, :string
      add_column :wisps, :redis_port, :string
      add_column :wisps, :redis_db, :string
  end

  def self.down
      remove_column :wisps, :redis_server
      remove_column :wisps, :redis_port
      remove_column :wisps, :redis_db
  end
end
