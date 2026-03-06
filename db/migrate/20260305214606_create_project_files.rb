class CreateProjectFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :project_files do |t|
      t.references :project, null: false, foreign_key: true
      t.references :uploader, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :label, null: false
      t.integer :version, null: false, default: 1

      t.timestamps
    end

    add_index :project_files, [ :project_id, :label, :version ], unique: true
    add_index :project_files, :created_at
  end
end
