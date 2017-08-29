describe LearningObjectives::ObjectivesController do
  let(:course) { create :course, :has_learning_objectives }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "GET index" do
      it "redirects to dashboard if learning objectives are not enabled for the course" do
        course.has_learning_objectives = false
        get :index
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "GET edit" do
      let!(:objective) { create :learning_objective, course: course }

      it "assigns the objective" do
        get :edit, params: { id: objective.id }
        expect(assigns :objective).to eq objective
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :index },
          -> { get :edit, params: { id: 1 } }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
