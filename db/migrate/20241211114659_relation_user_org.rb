class RelationUserOrg < ActiveRecord::Migration[7.2]
  def change
    create_table :organization_users do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
