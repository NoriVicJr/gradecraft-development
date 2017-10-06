describe LearningObjectives::CategoriesController do
  let(:course) { build :course, :has_learning_objectives }
  let(:category) { create :learning_objective_category, course: course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an instructor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "GET new" do
      it "assigns a category" do
        get :new
        expect(assigns :category).to be_a_new LearningObjectiveCategory
      end
    end

    describe "GET edit" do
      it "returns the category" do
        get :edit, params: { id: category.id }
        expect(assigns :category).to eq category
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :new },
          -> { get :edit, params: { id: category.id } }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
