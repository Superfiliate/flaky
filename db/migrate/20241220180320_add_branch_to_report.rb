class AddBranchToReport < ActiveRecord::Migration[8.0]
  def change
    add_column :reports, :branch, :string, null: false, default: "main"
  end
end
