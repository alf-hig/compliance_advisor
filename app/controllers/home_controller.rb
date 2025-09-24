class HomeController < ApplicationController
  def index
    # Landing page for the application
    @recent_assessments_count = Assessment.completed.recent.count
    @total_questions = Question.count
    @supported_states = InsuranceRequirement.distinct.pluck(:state).reject { |s| s == 'all' }.count
  end
  
  def about
    # About page explaining the service
  end
  
  def privacy
    # Privacy policy
  end
  
  def terms
    # Terms of service
  end
end
