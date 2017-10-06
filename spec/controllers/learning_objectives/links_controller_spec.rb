describe LearningObjectives::LinksController do
  let(:course) { build :course }
  let(:user) { build_stubbed :user, courses: [course], role: :student }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  describe "GET index" do
    context "when the current course does not have learning objectives enabled" do
      it "redirects to dashboard" do
        get :index
        expect(response).to redirect_to dashboard_path
      end
    end

    context "when the current course has learning objectives enabled" do
      let!(:learning_objective) { create :learning_objective, course: course }

      it "returns the objectives" do
        course.has_learning_objectives = true
        get :index
        expect(assigns :objectives).to eq [learning_objective]
      end
    end
  end
end
