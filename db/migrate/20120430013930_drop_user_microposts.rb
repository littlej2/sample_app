class DropUserMicroposts < ActiveRecord::Migration
  def self.up
     drop_table :microposts
  end

  def self.down
  end
end
