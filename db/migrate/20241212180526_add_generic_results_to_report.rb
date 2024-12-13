class AddGenericResultsToReport < ActiveRecord::Migration[7.2]
  def change
    add_column :reports, :results, :jsonb, null: false, default: {}
    add_column :reports, :expected_parts, :integer, null: false, default: 0
    add_column :reports, :run_identifer, :string
  end
end
