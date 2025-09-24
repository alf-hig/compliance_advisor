class Response < ApplicationRecord
  belongs_to :assessment
  belongs_to :question
  
  validates :answer_text, presence: true
  validates :question_id, uniqueness: { scope: :assessment_id }
  
  scope :recent, -> { where('created_at > ?', 30.days.ago) }
  scope :for_question_key, ->(key) { joins(:question).where(questions: { key: key }) }
  
  before_save :normalize_answer
  
  def boolean_answer
    case answer_text&.downcase
    when 'yes', 'true', '1'
      true
    when 'no', 'false', '0'
      false
    else
      nil
    end
  end
  
  def numeric_answer
    answer_text.to_i if answer_text.present?
  end
  
  def array_answer
    return [] unless answer_text.present?
    
    # Handle comma-separated values
    answer_text.split(',').map(&:strip).reject(&:blank?)
  end
  
  def formatted_answer
    case question.question_type
    when 'single_choice', 'dropdown'
      # Find the label for the selected option
      option = question.formatted_answer_options.find { |opt| opt[:value] == answer_text }
      option ? option[:label] : answer_text.humanize
    when 'multiple_choice'
      # Handle multiple selections
      selected_values = array_answer
      selected_options = question.formatted_answer_options.select { |opt| selected_values.include?(opt[:value]) }
      selected_options.map { |opt| opt[:label] }.join(', ')
    when 'text_input'
      answer_text
    when 'number_input'
      # Format numbers nicely
      if answer_text.to_i > 0
        number_with_delimiter(answer_text.to_i)
      else
        answer_text
      end
    else
      answer_text
    end
  end
  
  def self.for_assessment_and_question(assessment, question_key)
    joins(:question)
      .where(assessment: assessment, questions: { key: question_key })
      .first
  end
  
  private
  
  def normalize_answer
    return unless answer_text.present?
    
    # Normalize common answers
    self.answer_text = case answer_text.downcase.strip
                      when 'y', 'yes', 'true'
                        'yes'
                      when 'n', 'no', 'false'
                        'no'
                      else
                        answer_text.strip
                      end
  end
  
  def number_with_delimiter(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
