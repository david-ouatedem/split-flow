class CreateSplitEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :split_entries do |t|
      t.references :split_agreement, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :percentage, precision: 5, scale: 2, null: false
      t.datetime :approved_at

      t.timestamps
    end

    add_index :split_entries, [ :split_agreement_id, :user_id ], unique: true
    add_index :split_entries, :approved_at
  end
end
