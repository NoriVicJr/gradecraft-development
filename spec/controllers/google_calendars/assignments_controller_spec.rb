require "rails_spec_helper"
require "api_spec_helper"

describe GoogleCalendars::AssignmentsController, type:[:disable_external_api, :controller] do
  let(:provider) { :google_oauth2 }
  let(:course) { build :course }
  let!(:assignment_type) { create(:assignment_type, course: course) }
  let!(:assignment) { create(:assignment, assignment_type: assignment_type, course: course, due_at: DateTime.new(2017,4,1,17,0,0,-4)) }
  let!(:no_start_assignment) { create(:assignment, assignment_type: assignment_type, course: course, open_at: nil, due_at: DateTime.new(2017,4,1,17,0,0,-4)) }
  let!(:no_end_assignment) { create(:assignment, assignment_type: assignment_type, course: course, open_at: nil, due_at: nil) }
  let(:student) { build :user, courses: [course], role: :student }

  before do
    stub_request(:post, "https://accounts.google.com/o/oauth2/token").
      with(:body => {"client_id"=>"GOOGLE_CLIENT_ID", "client_secret"=>"GOOGLE_SECRET", "grant_type"=>""}).
      to_return(:status => 200, :body => "", :headers => {'Content-Type'=>'application/x-www-form-urlencoded'})

    stub_const('ENV', ENV.to_hash.merge('GOOGLE_CLIENT_ID' => 'GOOGLE_CLIENT_ID'))
    stub_const('ENV', ENV.to_hash.merge('GOOGLE_SECRET' => 'GOOGLE_SECRET'))

    allow(controller).to receive(:current_course).and_return course
  end

  before(:each) do
    login_user(student)
  end

  describe "POST add_assignment" do
    before(:each) do
      stub_request(:post, "https://www.googleapis.com/calendar/v3/calendars/primary/events").
        to_return(:status => 200, :body => "", :headers => {})
    end

    # Authorized User attempting add standard assignment
    context "with an existing authentication" do
      let! (:user_auth) { create :user_authorization, :google, user: student, access_token: "token", expires_at: 2.days.from_now}

      it "redirects to assignments path with a successful notice when attempting to add a standard assignment" do
        post :add_assignment, params: { class: "assignment", id: assignment.id }

        expect(response).to redirect_to assignment_path(assignment)
        expect(flash[:notice]).to eq("Item " + assignment.name + " successfully added to your Google Calendar")
      end

      # Authorized User attempting to add an assignment with no start date
      it "redirects to assignments path with a successful notice when attempting to add an assignment with no open date, generates open date to be 30 minutes prior to due date" do
        post :add_assignment, params: { class: "assignment", id: no_start_assignment.id}

        expect(response).to redirect_to assignment_path(no_start_assignment)
        expect(flash[:notice]).to eq("Item " + no_start_assignment.name + " successfully added to your Google Calendar")
      end

      # Authorized User attempting to add an assignment with no start and no end date
      it "redirects to assignments path with an alert notice when attempting to add an event with no due date" do
        post :add_assignment, params: { class: "assignment", id: no_end_assignment.id}

        expect(response).to redirect_to assignment_path(no_end_assignment)
        expect(flash[:alert]).to eq("Google Calendar requires Assignment to have at least END time!")
      end

      # Authorized User attempting to add a standard assignment without Google Client Id and Secret
      it "redirects to assignments path with an unsuccessful alert when user doesn't have proper Google Client Id and/or Secret" do

        stub_request(:post, 'https://accounts.google.com/o/oauth2/token').to_return(
          { status: 500, exception: Google::Apis::ServerError })

        post :add_assignment, params: { class: "assignment", id: assignment.id}

        expect(response).to redirect_to assignment_path(assignment)
        expect(flash[:alert]).to eq("Google Calendar encountered an Error. Your Assignment was NOT copied to your Google calendar.")
      end
    end

    # Unauthorized User attempting to add a standard assignment with no end date
    context "without an existing authentication" do
      it "redirects to google authentication page" do
        post :add_assignment, params: { class: "assignment", id: no_end_assignment.id}

        expect(response).to redirect_to "/auth/google_oauth2?prompt=consent"
      end
    end
  end

  describe "POST add_assignments" do
    before(:each) do
      stub_request(:post, "https://www.googleapis.com/batch").
        to_return(:status => 200, :body => "", :headers => {})
    end
    context "with an existing authentication" do
      let! (:user_auth) { create :user_authorization, :google, user: student, access_token: "token", expires_at: 2.days.from_now}

      it "redirects to assignments path with a failure alert when attempting to multiple assignments" do
        post :add_assignments, params: { class: "assignment"}

        expect(response).to redirect_to assignments_path
        expect(flash[:notice]).to eq("2 item(s) successfully added to your Google Calendar. 1 item(s) were not added because of missing due date(s).")
      end

      # Authorized User attempting to add a standard assignment without Google Client Id and Secret
      it "redirects to assignments path with an unsuccessful alert when user doesn't have proper Google Client Id and/or Secret" do

        stub_request(:post, 'https://accounts.google.com/o/oauth2/token').to_return(
          { status: 500, exception: Google::Apis::ServerError })

        post :add_assignments, params: { class: "assignment"}

        expect(response).to redirect_to assignments_path
        expect(flash[:alert]).to eq("Google Calendar encountered an Error. Your item was NOT copied to your Google calendar.")
      end
    end
  end



end
