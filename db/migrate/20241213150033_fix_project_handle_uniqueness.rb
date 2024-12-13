class FixProjectHandleUniqueness < ActiveRecord::Migration[7.2]
  def change
    add_index :projects, [:organization_id, :handle], unique: true
    remove_index :projects, :handle, unique: true
  end
end
