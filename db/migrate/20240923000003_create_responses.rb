class CreateResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :responses do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :answer_text, null: false
      t.text :additional_notes
      
      t.timestamps
    end
    
    add_index :responses, [:assessment_id, :question_id], unique: true
    add_index :responses, :created_at
  end
end
