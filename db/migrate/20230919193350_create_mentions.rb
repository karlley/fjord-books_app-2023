class CreateMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentions do |t|
      t.references :mention_source, null: false, foreign_key: { to_table: :reports }
      t.references :mention_target, null: false, foreign_key: { to_table: :reports }

      t.timestamps
    end
    add_index :mentions, %i[mention_source_id mention_target_id], unique: true
  end
end
