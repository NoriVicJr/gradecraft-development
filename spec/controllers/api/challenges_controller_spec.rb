include SessionHelper

describe API::ChallengesController do
  let(:course) { build_stubbed :course, add_team_score_to_student: true }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let!(:challenge) { create(:challenge, course: course) }
  let!(:team) { create(:team, course: course) }
  let!(:predicted_earned_challenge) { create :predicted_earned_challenge, student: student, challenge: challenge }
  let(:challenge_grade) { create(:challenge_grade, team_id: team.id, challenge_id: challenge.id) }

  context "as professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(professor)
    end

    describe "GET index" do
      it "assigns challenges, no grade or student" do
        get :index, format: :json
        expect(assigns(:challenges).first.id).to eq(challenge.id)
        expect(assigns :student).to be_nil
        expect(assigns :predicted_earned_challenges).to be_nil
        expect(assigns :grades).to be_nil
        expect(response).to render_template(:index)
      end
    end
  end

  context "as student" do
    before do
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(student)
      team_membership = create(:team_membership, team: team, student: student)
    end

    describe "GET index" do
      it "assigns the challenges with predictions and challenge grades and a call to update" do
        get :index, format: :json
        expect(assigns(:challenges).first.id).to eq(challenge.id)
        expect(assigns :student).to eq(student)
        expect(assigns :predicted_earned_challenges).to eq([predicted_earned_challenge])
        expect(assigns :grades).to eq([challenge_grade])
        expect(assigns(:allow_updates)).to be_truthy
        expect(response).to render_template(:index)
      end
    end
  end

  context "as faculty previewing as student" do
    before do
      login_as_impersonating_agent(professor, student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(student)
    end

    describe "GET index" do
      it "assigns false for updating predictions" do
        get :index, format: :json
        expect(assigns(:allow_updates)).to be_falsey
      end
    end
  end
end
