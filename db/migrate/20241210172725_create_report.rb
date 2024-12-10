class CreateReport < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.string :name, null: false
      t.string :kind, null: false

      t.timestamps
    end
  end
end
