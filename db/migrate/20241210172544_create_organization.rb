class CreateOrganization < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations do |t|
      t.timestamps
    end
  end
end
