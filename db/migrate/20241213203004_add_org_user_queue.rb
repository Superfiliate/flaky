class AddOrgUserQueue < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :user_queue, :jsonb, null: false, default: []
  end
end
