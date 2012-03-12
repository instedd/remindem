class AddLanguageToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :lang, :string, :limit => 10
  end
end
