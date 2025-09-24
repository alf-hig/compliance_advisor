class CreateAssessments < ActiveRecord::Migration[7.1]
  def change
    create_table :assessments do |t|
      t.string :session_id, null: false, index: { unique: true }
      t.integer :status, default: 0, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.text :user_agent
      t.string :ip_address
      
      t.timestamps
    end
    
    add_index :assessments, :status
    add_index :assessments, :created_at
  end
end
