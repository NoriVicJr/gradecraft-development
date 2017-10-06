describe API::LearningObjectives::CategoriesController do
  let(:course) { build :course }
  let(:category) { create :learning_objective_category, course: course }
  let(:attributes) { attributes_for :learning_objective_category }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an instructor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "GET index" do
      it "returns all categories for the current course" do
        categories = create_list :learning_objective_category, 2, course: course
        get :index, format: :json
        expect(assigns :categories).to match_array categories
        expect(response).to render_template :index
      end
    end

    describe "GET show" do
      it "returns the category" do
        get :show, params: { id: category.id} , format: :json
        expect(assigns :category).to eq category
        expect(response).to render_template "api/learning_objectives/categories/show"
      end
    end

    describe "POST create" do
      it "creates a category on success" do
        expect{ post :create, params: { learning_objective_category: attributes}, format: :json }.to \
          change(LearningObjectiveCategory, :count).by 1
        expect(response).to render_template "api/learning_objectives/categories/show"
      end
    end

    describe "PUT update" do
      it "updates the category" do
        attributes[:description] = Faker::Hacker.say_something_smart
        put :update, params: { learning_objective_category: attributes, id: category.id }, format: :json
        expect(category.reload).to have_attributes attributes
        expect(response).to render_template "api/learning_objectives/categories/show"
      end
    end

    describe "DELETE destroy" do
      it "deletes the category" do
        category
        expect{ delete :destroy, params: { id: category.id }, format: :json }.to \
          change(LearningObjectiveCategory, :count).by -1
        expect(response).to have_http_status :ok
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :index, format: :json },
          -> { get :show, params: { id: category.id }, format: :json },
          -> { post :create, format: :json},
          -> { put :update, params: { id: category.id }, format: :json },
          -> { delete :destroy, params: { id: category.id }, format: :json}
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
