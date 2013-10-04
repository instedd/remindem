class AddFeaturesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :features, :text
  end

  def self.down
    remove_column :users, :features
  end
end
