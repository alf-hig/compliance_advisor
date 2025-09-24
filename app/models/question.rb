class Question < ApplicationRecord
  has_many :responses, dependent: :destroy
  
  validates :key, presence: true, uniqueness: true
  validates :text, presence: true
  validates :question_type, presence: true
  validates :order_position, presence: true, uniqueness: true
  
  enum :question_type, {
    single_choice: 0,
    multiple_choice: 1,
    text_input: 2,
    number_input: 3,
    dropdown: 4
  }
  
  scope :ordered, -> { order(:order_position) }
  scope :conditional, -> { where.not(show_if_conditions: nil) }
  
  def self.next_question_for(last_response)
    return first_question unless last_response
    
    current_question = last_response.question
    assessment = last_response.assessment
    
    # Get all questions after the current one
    remaining_questions = where('order_position > ?', current_question.order_position).ordered
    
    # Find the first question that should be shown based on conditions
    remaining_questions.find { |q| q.should_show_for_assessment?(assessment) }
  end
  
  def self.first_question
    ordered.first
  end
  
  def should_show_for_assessment?(assessment)
    return true if show_if_conditions.blank?
    
    # Evaluate conditions based on previous responses
    show_if_conditions.all? do |condition|
      evaluate_condition(condition, assessment)
    end
  end
  
  def formatted_answer_options
    return [] unless answer_options.is_a?(Array)
    
    answer_options.map do |option|
      if option.is_a?(Hash)
        {
          value: option['value'],
          label: option['label'],
          description: option['description']
        }
      else
        {
          value: option,
          label: option.humanize,
          description: nil
        }
      end
    end
  end
  
  def has_description?
    description.present?
  end
  
  def has_help_text?
    help_text.present?
  end
  
  private
  
  def evaluate_condition(condition, assessment)
    question_key = condition['question_key']
    expected_value = condition['value']
    operator = condition['operator'] || 'equals'
    
    response = assessment.responses.joins(:question)
                         .where(questions: { key: question_key })
                         .first
    
    return false unless response
    
    actual_value = response.answer_text
    
    case operator
    when 'equals'
      actual_value == expected_value
    when 'not_equals'
      actual_value != expected_value
    when 'includes'
      actual_value&.include?(expected_value)
    when 'greater_than'
      actual_value.to_i > expected_value.to_i
    when 'less_than'
      actual_value.to_i < expected_value.to_i
    else
      false
    end
  end
end
