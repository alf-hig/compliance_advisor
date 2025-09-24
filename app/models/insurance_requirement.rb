class InsuranceRequirement < ApplicationRecord
  validates :insurance_type, presence: true
  validates :state, presence: true
  validates :priority, presence: true
  
  enum :priority, {
    mandatory: 0,
    required_for_licenses: 1,
    contractually_required: 2,
    highly_recommended: 3
  }
  
  enum :insurance_type, {
    workers_compensation: 0,
    general_liability: 1,
    professional_liability: 2,
    commercial_auto: 3,
    cyber_liability: 4,
    errors_omissions: 5,
    product_liability: 6,
    commercial_property: 7,
    business_interruption: 8,
    employment_practices: 9,
    directors_officers: 10,
    commercial_umbrella: 11,
    surety_bonds: 12,
    liquor_liability: 13,
    pollution_liability: 14
  }
  
  scope :for_state, ->(state) { where(state: [state, 'all']) }
  scope :for_industry, ->(industry) { where('industry IS NULL OR industry = ?', industry) }
  scope :mandatory_only, -> { where(priority: :mandatory) }
  
  def self.applicable_requirements(assessment)
    location = assessment.business_location
    state = location[:state]
    industry = assessment.primary_industry
    
    requirements = for_state(state).for_industry(industry)
    
    # Filter based on specific conditions
    requirements.select do |req|
      req.applies_to_assessment?(assessment)
    end
  end
  
  def applies_to_assessment?(assessment)
    return true if conditions.blank?
    
    conditions.all? do |condition|
      evaluate_condition(condition, assessment)
    end
  end
  
  def formatted_description
    base_description = case insurance_type
    when 'workers_compensation'
      'Covers medical expenses and lost wages for employees injured on the job'
    when 'general_liability'
      'Protects against claims of bodily injury, property damage, and personal injury'
    when 'professional_liability'
      'Covers claims related to professional services, errors, and omissions'
    when 'commercial_auto'
      'Required for vehicles used for business purposes'
    when 'cyber_liability'
      'Protects against data breaches and cyber attacks'
    when 'errors_omissions'
      'Covers professional mistakes and failure to deliver services'
    else
      description
    end
    
    base_description + additional_context
  end
  
  def legal_basis
    case priority
    when 'mandatory'
      'Required by state law'
    when 'required_for_licenses'
      'Required to maintain professional license'
    when 'contractually_required'
      'Required by most commercial contracts'
    when 'highly_recommended'
      'Strongly recommended for business protection'
    end
  end
  
  def formatted_minimum_coverage
    return 'Varies by state' unless minimum_coverage.present?
    
    if minimum_coverage['per_occurrence'] && minimum_coverage['aggregate']
      "$#{format_currency(minimum_coverage['per_occurrence'])} per occurrence / " +
      "$#{format_currency(minimum_coverage['aggregate'])} aggregate"
    elsif minimum_coverage['amount']
      "$#{format_currency(minimum_coverage['amount'])}"
    else
      'Coverage amounts vary'
    end
  end
  
  def next_steps
    case insurance_type
    when 'workers_compensation'
      [
        'Contact your state\'s workers\' compensation board',
        'Get quotes from licensed insurance carriers',
        'Ensure coverage begins before your first employee starts work'
      ]
    when 'general_liability'
      [
        'Compare quotes from multiple insurance providers',
        'Consider bundling with other business insurance',
        'Review coverage limits based on your business risks'
      ]
    when 'commercial_auto'
      [
        'Contact your auto insurance provider about commercial coverage',
        'List all vehicles used for business',
        'Consider hired and non-owned auto coverage'
      ]
    else
      [
        'Research licensed insurance providers in your state',
        'Get multiple quotes to compare coverage and pricing',
        'Consult with an insurance agent about your specific needs'
      ]
    end
  end
  
  private
  
  def evaluate_condition(condition, assessment)
    case condition['type']
    when 'has_employees'
      assessment.has_employees?
    when 'employee_count_greater_than'
      assessment.employee_count > condition['value'].to_i
    when 'uses_vehicles'
      assessment.uses_vehicles?
    when 'has_government_contracts'
      assessment.has_government_contracts?
    when 'works_on_client_premises'
      assessment.works_on_client_premises?
    when 'has_commercial_lease'
      assessment.has_commercial_lease?
    when 'revenue_greater_than'
      assessment.annual_revenue > condition['value'].to_i
    when 'handles_sensitive_data'
      assessment.handles_sensitive_data?
    when 'professional_license'
      assessment.professional_licenses.any? { |license| license.downcase.include?(condition['value'].downcase) }
    else
      true
    end
  end
  
  def additional_context
    context_parts = []
    
    if exemptions.present?
      context_parts << "\n\nExemptions may apply for: #{exemptions.join(', ')}"
    end
    
    if conditions.present?
      context_parts << "\n\nThis requirement applies when: #{format_conditions}"
    end
    
    context_parts.join
  end
  
  def format_conditions
    conditions.map do |condition|
      case condition['type']
      when 'has_employees'
        'you have employees'
      when 'employee_count_greater_than'
        "you have more than #{condition['value']} employees"
      when 'uses_vehicles'
        'you use vehicles for business'
      when 'revenue_greater_than'
        "annual revenue exceeds $#{format_currency(condition['value'])}"
      else
        condition['description'] || condition['type'].humanize
      end
    end.join(' and ')
  end
  
  def format_currency(amount)
    amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
