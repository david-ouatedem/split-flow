class CreateSplitAgreements < ActiveRecord::Migration[8.1]
  def change
    create_table :split_agreements do |t|
      t.references :project, null: false, foreign_key: true, index: { unique: true }
      t.integer :status, null: false, default: 0
      t.datetime :locked_at
      t.string :verification_token, null: false

      t.timestamps
    end

    add_index :split_agreements, :status
    add_index :split_agreements, :verification_token, unique: true
  end
end
