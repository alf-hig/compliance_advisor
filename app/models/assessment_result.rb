class AssessmentResult < ApplicationRecord
  belongs_to :assessment
  belongs_to :insurance_requirement
  
  validates :assessment_id, uniqueness: { scope: :insurance_requirement_id }
  
  enum :recommendation_strength, {
    legally_required: 0,
    license_required: 1,
    contract_required: 2,
    strongly_recommended: 3,
    worth_considering: 4
  }
  
  scope :required, -> { where(recommendation_strength: [:legally_required, :license_required]) }
  scope :recommended, -> { where(recommendation_strength: [:contract_required, :strongly_recommended]) }
  scope :optional, -> { where(recommendation_strength: :worth_considering) }
  
  def self.generate_for_assessment(assessment)
    # Clear existing results
    where(assessment: assessment).destroy_all
    
    applicable_requirements = InsuranceRequirement.applicable_requirements(assessment)
    
    applicable_requirements.each do |requirement|
      strength = determine_recommendation_strength(requirement, assessment)
      explanation = generate_explanation(requirement, assessment)
      
      create!(
        assessment: assessment,
        insurance_requirement: requirement,
        recommendation_strength: strength,
        explanation: explanation,
        estimated_annual_cost: estimate_cost(requirement, assessment)
      )
    end
  end
  
  def self.determine_recommendation_strength(requirement, assessment)
    case requirement.priority
    when 'mandatory'
      :legally_required
    when 'required_for_licenses'
      :license_required
    when 'contractually_required'
      assessment.has_government_contracts? || assessment.works_on_client_premises? ? :contract_required : :strongly_recommended
    else
      :strongly_recommended
    end
  end
  
  def self.generate_explanation(requirement, assessment)
    base_explanation = requirement.legal_basis
    
    specific_reasons = []
    
    case requirement.insurance_type
    when 'workers_compensation'
      if assessment.has_employees?
        specific_reasons << "You have #{assessment.employee_count} employee(s)"
      end
    when 'commercial_auto'
      if assessment.uses_vehicles?
        specific_reasons << "You use vehicles for business purposes"
      end
    when 'general_liability'
      reasons = []
      reasons << "You work on client premises" if assessment.works_on_client_premises?
      reasons << "You have a commercial lease" if assessment.has_commercial_lease?
      reasons << "You have government contracts" if assessment.has_government_contracts?
      specific_reasons.concat(reasons)
    when 'cyber_liability'
      if assessment.handles_sensitive_data?
        specific_reasons << "You handle sensitive customer data"
      end
    when 'professional_liability'
      if assessment.professional_licenses.any?
        specific_reasons << "You hold professional licenses: #{assessment.professional_licenses.join(', ')}"
      end
    end
    
    explanation = base_explanation
    if specific_reasons.any?
      explanation += ". Specifically for your business: #{specific_reasons.join(', ')}"
    end
    
    explanation
  end
  
  def self.estimate_cost(requirement, assessment)
    # Simple cost estimation based on industry averages
    base_costs = {
      'workers_compensation' => 500,
      'general_liability' => 400,
      'professional_liability' => 800,
      'commercial_auto' => 1200,
      'cyber_liability' => 600,
      'errors_omissions' => 800,
      'commercial_property' => 700,
      'employment_practices' => 500
    }
    
    base_cost = base_costs[requirement.insurance_type] || 500
    
    # Adjust based on business factors
    multiplier = 1.0
    
    # Employee count affects some insurance types
    if ['workers_compensation', 'employment_practices'].include?(requirement.insurance_type)
      multiplier *= [1.0 + (assessment.employee_count * 0.2), 3.0].min
    end
    
    # Revenue affects liability limits
    if assessment.annual_revenue > 100_000
      multiplier *= 1.2
    elsif assessment.annual_revenue > 500_000
      multiplier *= 1.5
    end
    
    # High-risk industries
    high_risk_industries = ['construction', 'healthcare', 'legal', 'accounting', 'consulting']
    if high_risk_industries.any? { |industry| assessment.primary_industry&.downcase&.include?(industry) }
      multiplier *= 1.3
    end
    
    (base_cost * multiplier).round
  end
  
  def priority_badge_class
    case recommendation_strength
    when 'legally_required'
      'bg-red-100 text-red-800 border-red-200'
    when 'license_required'
      'bg-orange-100 text-orange-800 border-orange-200'
    when 'contract_required'
      'bg-yellow-100 text-yellow-800 border-yellow-200'
    when 'strongly_recommended'
      'bg-blue-100 text-blue-800 border-blue-200'
    else
      'bg-gray-100 text-gray-800 border-gray-200'
    end
  end
  
  def priority_label
    case recommendation_strength
    when 'legally_required'
      'Legally Required'
    when 'license_required'
      'License Requirement'
    when 'contract_required'
      'Contract Requirement'
    when 'strongly_recommended'
      'Strongly Recommended'
    else
      'Worth Considering'
    end
  end
  
  def formatted_cost
    return 'Cost varies' unless estimated_annual_cost
    
    "$#{number_with_delimiter(estimated_annual_cost)}/year (estimated)"
  end
  
  private
  
  def number_with_delimiter(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
