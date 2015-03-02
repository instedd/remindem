class AddTypeToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :external_actions, :text
    add_column :messages, :type, :string
  end
end
