class CreateProject < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
