class Assessment < ApplicationRecord
  has_many :responses, dependent: :destroy
  has_many :assessment_results, dependent: :destroy
  
  validates :session_id, presence: true, uniqueness: true
  
  enum :status, {
    started: 0,
    in_progress: 1,
    completed: 2
  }
  
  scope :recent, -> { where('created_at > ?', 30.days.ago) }
  scope :completed, -> { where(status: :completed) }
  
  def current_question
    return Question.first if responses.empty?
    
    # Find the next question based on responses and logic
    last_response = responses.order(:created_at).last
    Question.next_question_for(last_response)
  end
  
  def progress_percentage
    return 0 if responses.empty?
    
    total_questions = Question.count
    answered_questions = responses.count
    
    [(answered_questions.to_f / total_questions * 100).round, 100].min
  end
  
  def business_location
    state_response = responses.joins(:question).where(questions: { key: 'business_state' }).first
    city_response = responses.joins(:question).where(questions: { key: 'business_city' }).first
    
    {
      state: state_response&.answer_text,
      city: city_response&.answer_text
    }
  end
  
  def business_structure
    response = responses.joins(:question).where(questions: { key: 'business_structure' }).first
    response&.answer_text
  end
  
  def has_employees?
    response = responses.joins(:question).where(questions: { key: 'has_employees' }).first
    response&.answer_text == 'yes'
  end
  
  def employee_count
    response = responses.joins(:question).where(questions: { key: 'employee_count' }).first
    response&.answer_text&.to_i || 0
  end
  
  def primary_industry
    response = responses.joins(:question).where(questions: { key: 'primary_industry' }).first
    response&.answer_text
  end
  
  def professional_licenses
    response = responses.joins(:question).where(questions: { key: 'professional_licenses' }).first
    response&.answer_text&.split(',')&.map(&:strip) || []
  end
  
  def uses_vehicles?
    response = responses.joins(:question).where(questions: { key: 'uses_vehicles' }).first
    response&.answer_text == 'yes'
  end
  
  def has_government_contracts?
    response = responses.joins(:question).where(questions: { key: 'government_contracts' }).first
    response&.answer_text == 'yes'
  end
  
  def works_on_client_premises?
    response = responses.joins(:question).where(questions: { key: 'client_premises' }).first
    response&.answer_text == 'yes'
  end
  
  def has_commercial_lease?
    response = responses.joins(:question).where(questions: { key: 'commercial_lease' }).first
    response&.answer_text == 'yes'
  end
  
  def annual_revenue
    response = responses.joins(:question).where(questions: { key: 'annual_revenue' }).first
    response&.answer_text&.to_i || 0
  end
  
  def handles_sensitive_data?
    response = responses.joins(:question).where(questions: { key: 'sensitive_data' }).first
    response&.answer_text == 'yes'
  end
end
