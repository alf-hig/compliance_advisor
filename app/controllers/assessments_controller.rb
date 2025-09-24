class AssessmentsController < ApplicationController
  before_action :find_or_create_assessment, except: [:results]
  before_action :find_assessment_by_session, only: [:results]
  
  def start
    # Initialize or reset the assessment
    @assessment.update!(
      status: :started,
      started_at: Time.current,
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    
    # Clear any existing responses for fresh start
    @assessment.responses.destroy_all
    
    redirect_to assessment_question_path(@assessment.session_id)
  end
  
  def question
    @current_question = @assessment.current_question
    
    if @current_question.nil?
      # No more questions, generate results
      generate_assessment_results
      redirect_to assessment_results_path(@assessment.session_id)
      return
    end
    
    @progress_percentage = @assessment.progress_percentage
    @response = Response.new
    
    # Get any existing response for this question
    @existing_response = @assessment.responses
                                   .joins(:question)
                                   .where(questions: { key: @current_question.key })
                                   .first
    
    if @existing_response
      @response.answer_text = @existing_response.answer_text
    end
  end
  
  def answer
    @current_question = Question.find(params[:question_id])
    answer_text = params[:response][:answer_text]
    
    # Validate required fields
    if answer_text.blank?
      flash[:error] = "Please provide an answer to continue."
      redirect_to assessment_question_path(@assessment.session_id)
      return
    end
    
    # Save or update the response
    @response = Response.find_or_initialize_by(
      assessment: @assessment,
      question: @current_question
    )
    
    @response.answer_text = answer_text
    @response.additional_notes = params[:response][:additional_notes]
    
    if @response.save
      @assessment.update!(status: :in_progress)
      
      # Check if there are more questions
      next_question = Question.next_question_for(@response)
      
      if next_question
        redirect_to assessment_question_path(@assessment.session_id)
      else
        # Assessment complete, generate results
        generate_assessment_results
        redirect_to assessment_results_path(@assessment.session_id)
      end
    else
      flash[:error] = "There was an error saving your response. Please try again."
      redirect_to assessment_question_path(@assessment.session_id)
    end
  end
  
  def back
    # Find the previous question based on current responses
    current_responses = @assessment.responses.joins(:question).order('questions.order_position DESC')
    
    if current_responses.any?
      # Remove the last response to go back
      last_response = current_responses.first
      last_response.destroy
      
      flash[:info] = "Moved back to previous question."
    end
    
    redirect_to assessment_question_path(@assessment.session_id)
  end
  
  def results
    return redirect_to root_path unless @assessment
    
    # Ensure results are generated
    if @assessment.assessment_results.empty?
      generate_assessment_results
    end
    
    @results = @assessment.assessment_results
                          .includes(:insurance_requirement)
                          .order(:recommendation_strength)
    
    @required_insurance = @results.required
    @recommended_insurance = @results.recommended
    @optional_insurance = @results.optional
    
    @total_estimated_cost = @results.sum(:estimated_annual_cost) || 0
    
    # Mark assessment as completed
    @assessment.update!(
      status: :completed,
      completed_at: Time.current
    ) unless @assessment.completed?
  end
  
  def restart
    if @assessment
      @assessment.responses.destroy_all
      @assessment.assessment_results.destroy_all
      @assessment.update!(
        status: :started,
        started_at: Time.current,
        completed_at: nil
      )
    end
    
    redirect_to assessment_start_path(@assessment.session_id)
  end
  
  private
  
  def find_or_create_assessment
    session_id = params[:session_id] || params[:id]
    
    if session_id.present?
      @assessment = Assessment.find_by(session_id: session_id)
    end
    
    if @assessment.nil?
      # Create new assessment with unique session ID
      @assessment = Assessment.create!(
        session_id: generate_session_id,
        status: :started
      )
    end
    
    # Store session ID in user session for persistence
    session[:assessment_session_id] = @assessment.session_id
  end
  
  def find_assessment_by_session
    session_id = params[:session_id] || params[:id]
    @assessment = Assessment.find_by(session_id: session_id)
    
    unless @assessment
      flash[:error] = "Assessment not found. Please start a new assessment."
      redirect_to root_path
    end
  end
  
  def generate_session_id
    loop do
      session_id = SecureRandom.hex(16)
      break session_id unless Assessment.exists?(session_id: session_id)
    end
  end
  
  def generate_assessment_results
    return if @assessment.assessment_results.any?
    
    AssessmentResult.generate_for_assessment(@assessment)
  end
end
