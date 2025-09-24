class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :key, null: false, index: { unique: true }
      t.text :text, null: false
      t.text :description
      t.text :help_text
      t.integer :question_type, null: false, default: 0
      t.json :answer_options
      t.json :show_if_conditions
      t.integer :order_position, null: false, index: { unique: true }
      t.boolean :required, default: true, null: false
      t.string :category
      
      t.timestamps
    end
    
    add_index :questions, :question_type
    add_index :questions, :category
  end
end
