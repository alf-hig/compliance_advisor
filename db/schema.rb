# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_09_23_000005) do
  create_table "assessment_results", force: :cascade do |t|
    t.integer "assessment_id", null: false
    t.integer "insurance_requirement_id", null: false
    t.integer "recommendation_strength", default: 0, null: false
    t.text "explanation"
    t.integer "estimated_annual_cost"
    t.json "additional_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id", "insurance_requirement_id"], name: "index_assessment_results_unique", unique: true
    t.index ["assessment_id"], name: "index_assessment_results_on_assessment_id"
    t.index ["insurance_requirement_id"], name: "index_assessment_results_on_insurance_requirement_id"
    t.index ["recommendation_strength"], name: "index_assessment_results_on_recommendation_strength"
  end

  create_table "assessments", force: :cascade do |t|
    t.string "session_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_assessments_on_created_at"
    t.index ["session_id"], name: "index_assessments_on_session_id", unique: true
    t.index ["status"], name: "index_assessments_on_status"
  end

  create_table "insurance_requirements", force: :cascade do |t|
    t.integer "insurance_type", null: false
    t.string "state", null: false
    t.string "industry"
    t.integer "priority", default: 0, null: false
    t.text "description"
    t.json "conditions"
    t.json "minimum_coverage"
    t.json "exemptions"
    t.text "legal_reference"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_insurance_requirements_on_active"
    t.index ["industry"], name: "index_insurance_requirements_on_industry"
    t.index ["insurance_type", "state"], name: "index_insurance_requirements_on_insurance_type_and_state"
    t.index ["priority"], name: "index_insurance_requirements_on_priority"
    t.index ["state"], name: "index_insurance_requirements_on_state"
  end

  create_table "questions", force: :cascade do |t|
    t.string "key", null: false
    t.text "text", null: false
    t.text "description"
    t.text "help_text"
    t.integer "question_type", default: 0, null: false
    t.json "answer_options"
    t.json "show_if_conditions"
    t.integer "order_position", null: false
    t.boolean "required", default: true, null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_questions_on_category"
    t.index ["key"], name: "index_questions_on_key", unique: true
    t.index ["order_position"], name: "index_questions_on_order_position", unique: true
    t.index ["question_type"], name: "index_questions_on_question_type"
  end

  create_table "responses", force: :cascade do |t|
    t.integer "assessment_id", null: false
    t.integer "question_id", null: false
    t.text "answer_text", null: false
    t.text "additional_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id", "question_id"], name: "index_responses_on_assessment_id_and_question_id", unique: true
    t.index ["assessment_id"], name: "index_responses_on_assessment_id"
    t.index ["created_at"], name: "index_responses_on_created_at"
    t.index ["question_id"], name: "index_responses_on_question_id"
  end

  add_foreign_key "assessment_results", "assessments"
  add_foreign_key "assessment_results", "insurance_requirements"
  add_foreign_key "responses", "assessments"
  add_foreign_key "responses", "questions"
end
