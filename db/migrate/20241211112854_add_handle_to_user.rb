class AddHandleToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :handle, :string
    add_index :users, :handle
  end
end
