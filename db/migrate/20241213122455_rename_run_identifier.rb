class RenameRunIdentifier < ActiveRecord::Migration[7.2]
  def change
    rename_column :reports, :run_identifer, :run_identifier
  end
end
