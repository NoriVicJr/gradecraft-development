describe LearningObjectives::ObjectivesController do
  let(:course) { build_stubbed :course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "GET index" do
      context "when learning objectives are not enabled for the course" do
        it "redirects to dashboard" do
          get :index
          expect(response).to redirect_to dashboard_path
        end
      end

      context "when learning objectives are enabled for the course" do
        let(:course) { build_stubbed :course, :has_learning_objectives }

        it "redirects to setup if no objectives exist" do
          get :index
          expect(response).to redirect_to setup_learning_objectives_path
        end
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :index },
          -> { get :setup }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
