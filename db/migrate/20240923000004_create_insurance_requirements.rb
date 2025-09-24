class CreateInsuranceRequirements < ActiveRecord::Migration[7.1]
  def change
    create_table :insurance_requirements do |t|
      t.integer :insurance_type, null: false
      t.string :state, null: false
      t.string :industry
      t.integer :priority, null: false, default: 0
      t.text :description
      t.json :conditions
      t.json :minimum_coverage
      t.json :exemptions
      t.text :legal_reference
      t.boolean :active, default: true, null: false
      
      t.timestamps
    end
    
    add_index :insurance_requirements, [:insurance_type, :state]
    add_index :insurance_requirements, :state
    add_index :insurance_requirements, :industry
    add_index :insurance_requirements, :priority
    add_index :insurance_requirements, :active
  end
end
