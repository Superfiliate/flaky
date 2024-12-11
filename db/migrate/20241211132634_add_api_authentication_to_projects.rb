class AddApiAuthenticationToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :handle, :string
    add_index :projects, :handle, unique: true
    add_column :projects, :api_auth_digest, :string

    add_column :organizations, :handle, :string
    add_index :organizations, :handle, unique: true
  end
end
