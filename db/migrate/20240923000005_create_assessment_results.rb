class CreateAssessmentResults < ActiveRecord::Migration[7.1]
  def change
    create_table :assessment_results do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :insurance_requirement, null: false, foreign_key: true
      t.integer :recommendation_strength, null: false, default: 0
      t.text :explanation
      t.integer :estimated_annual_cost
      t.json :additional_details
      
      t.timestamps
    end
    
    add_index :assessment_results, [:assessment_id, :insurance_requirement_id], 
              unique: true, name: 'index_assessment_results_unique'
    add_index :assessment_results, :recommendation_strength
  end
end
