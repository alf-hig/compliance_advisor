# Clear existing data in development
if Rails.env.development?
  AssessmentResult.destroy_all
  Response.destroy_all
  Assessment.destroy_all
  InsuranceRequirement.destroy_all
  Question.destroy_all
end

puts "Creating questions..."

# Foundation Questions: Location and Business Structure
questions_data = [
  {
    key: 'business_state',
    text: 'In which state is your business registered or primarily operating?',
    description: 'This is the most important question as insurance requirements vary significantly by state.',
    help_text: 'Choose the state where your business is legally registered or where you conduct most of your business activities.',
    question_type: 'dropdown',
    answer_options: [
      { value: 'CA', label: 'California' },
      { value: 'NY', label: 'New York' },
      { value: 'FL', label: 'Florida' },
      { value: 'TX', label: 'Texas' },
      { value: 'IL', label: 'Illinois' },
      { value: 'PA', label: 'Pennsylvania' },
      { value: 'OH', label: 'Ohio' },
      { value: 'GA', label: 'Georgia' },
      { value: 'NC', label: 'North Carolina' }
    ],
    order_position: 1,
    category: 'location'
  },
  {
    key: 'business_structure',
    text: 'How is your business legally structured?',
    description: 'Different business structures have different insurance requirements and liability exposures.',
    help_text: 'If you\'re unsure, most solopreneurs start as sole proprietors.',
    question_type: 'single_choice',
    answer_options: [
      { 
        value: 'sole_proprietorship', 
        label: 'Sole Proprietorship',
        description: 'I\'m the only owner and haven\'t formed an LLC or corporation'
      },
      { 
        value: 'llc', 
        label: 'Limited Liability Company (LLC)',
        description: 'I\'ve formed an LLC for liability protection'
      },
      { 
        value: 'corporation', 
        label: 'Corporation (S-Corp or C-Corp)',
        description: 'I\'ve incorporated my business'
      }
    ],
    order_position: 2,
    category: 'structure'
  },
  {
    key: 'primary_industry',
    text: 'What is your primary business activity or industry?',
    description: 'Different industries have specific insurance requirements mandated by law or licensing boards.',
    question_type: 'dropdown',
    answer_options: [
      { value: 'consulting', label: 'Consulting & Professional Services' },
      { value: 'construction', label: 'Construction & Contracting' },
      { value: 'healthcare', label: 'Healthcare & Medical Services' },
      { value: 'legal', label: 'Legal Services' },
      { value: 'accounting', label: 'Accounting & Financial Services' },
      { value: 'technology', label: 'Technology & Software Development' },
      { value: 'other', label: 'Other' }
    ],
    order_position: 3,
    category: 'business'
  },
  {
    key: 'has_employees',
    text: 'Do you have any employees (including part-time)?',
    description: 'Workers\' compensation insurance is mandatory in almost every state once you have employees.',
    question_type: 'single_choice',
    answer_options: [
      { value: 'yes', label: 'Yes, I have employees' },
      { value: 'no', label: 'No, I work alone' }
    ],
    order_position: 4,
    category: 'employment'
  },
  {
    key: 'employee_count',
    text: 'How many employees do you have?',
    description: 'The number of employees affects insurance requirements and costs.',
    question_type: 'number_input',
    show_if_conditions: [
      { question_key: 'has_employees', value: 'yes', operator: 'equals' }
    ],
    order_position: 5,
    category: 'employment'
  }
]

questions_data.each do |question_data|
  Question.create!(question_data)
end

puts "Created #{Question.count} questions"

puts "Creating insurance requirements..."

# Workers' Compensation Requirements - mandatory in most states when you have employees
insurance_requirements_data = [
  {
    insurance_type: 'workers_compensation',
    state: 'CA',
    priority: 'mandatory',
    description: 'Provides medical benefits and wage replacement for employees injured on the job.',
    conditions: [{ type: 'has_employees', value: true }],
    minimum_coverage: { 'varies_by_state' => true },
    legal_reference: 'California Labor Code Section 3700'
  },
  {
    insurance_type: 'workers_compensation',
    state: 'NY',
    priority: 'mandatory',
    description: 'Provides medical benefits and wage replacement for employees injured on the job.',
    conditions: [{ type: 'has_employees', value: true }],
    minimum_coverage: { 'varies_by_state' => true },
    legal_reference: 'New York Workers\' Compensation Law'
  },
  {
    insurance_type: 'workers_compensation',
    state: 'FL',
    priority: 'mandatory',
    description: 'Provides medical benefits and wage replacement for employees injured on the job.',
    conditions: [{ type: 'has_employees', value: true }],
    minimum_coverage: { 'varies_by_state' => true },
    legal_reference: 'Florida Statutes Chapter 440'
  },
  # General Liability for certain activities
  {
    insurance_type: 'general_liability',
    state: 'all',
    industry: 'construction',
    priority: 'mandatory',
    description: 'Required for construction contractors in most jurisdictions.',
    minimum_coverage: { 'per_occurrence' => 1000000, 'aggregate' => 2000000 },
    legal_reference: 'State contractor licensing requirements'
  },
  # Professional Liability for licensed professionals
  {
    insurance_type: 'professional_liability',
    state: 'all',
    industry: 'legal',
    priority: 'required_for_licenses',
    description: 'Required for maintaining legal practice license.',
    conditions: [{ type: 'professional_license', value: 'legal' }],
    minimum_coverage: { 'per_claim' => 1000000, 'aggregate' => 3000000 }
  },
  {
    insurance_type: 'professional_liability',
    state: 'all',
    industry: 'accounting',
    priority: 'required_for_licenses',
    description: 'Required for CPA license in most states.',
    conditions: [{ type: 'professional_license', value: 'accounting' }],
    minimum_coverage: { 'per_claim' => 1000000, 'aggregate' => 3000000 }
  },
  {
    insurance_type: 'professional_liability',
    state: 'all',
    industry: 'healthcare',
    priority: 'mandatory',
    description: 'Medical malpractice insurance required for healthcare providers.',
    conditions: [{ type: 'professional_license', value: 'healthcare' }],
    minimum_coverage: { 'per_claim' => 1000000, 'aggregate' => 3000000 }
  }
]

insurance_requirements_data.each do |req_data|
  InsuranceRequirement.create!(req_data)
end

puts "Created #{InsuranceRequirement.count} insurance requirements"
puts "Seed data creation complete!"
