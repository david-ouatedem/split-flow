class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string     :title,      null: false
      t.text       :description
      t.string     :genre
      t.integer    :bpm
      t.integer    :visibility, null: false, default: 0
      t.integer    :status,     null: false, default: 0
      t.references :owner,      null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :projects, :visibility
    add_index :projects, :status
  end
end
