describe API::LearningObjectives::LevelsController do
  let(:course) { build :course }
  let!(:objective) { create :learning_objective, course: course }
  let(:level) { create :learning_objective_level, objective: objective }
  let(:attributes) { attributes_for :learning_objective_level }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as an instructor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "POST create" do
      it "creates the level" do
        expect{ post :create, params: { objective_id: objective.id, learning_objective_level: attributes }, format: :json }.to \
          change(LearningObjectiveLevel, :count).by 1
        expect(response).to render_template "api/learning_objectives/levels/show"
      end
    end

    describe "PUT update" do
      it "updates the level" do
        attributes[:description] = Faker::Company.catch_phrase
        put :update, params: { objective_id: objective.id, id: level.id, learning_objective_level: attributes }, format: :json
        expect(level.reload.description).to eq attributes[:description]
        expect(response).to render_template "api/learning_objectives/levels/show"
      end
    end

    describe "DELETE destroy" do
      it "deletes the level" do
        level
        expect{ delete :destroy, params: { objective_id: objective.id, id: level.id }, format: :json }.to \
          change(LearningObjectiveLevel, :count).by -1
      end
    end

    describe "PUT update_order" do
      it "updates the ordering" do
        level
        another_level = create :learning_objective_level, objective: objective
        put :update_order, params: { objective_id: objective.id, level_ids: [another_level.id, level.id] }, format: :json
        expect(objective.reload.levels).to eq [another_level, level]
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { post :create, params: { objective_id: objective.id }, format: :json },
          -> { put :update, params: { objective_id: objective.id, id: level.id, learning_objective_level: attributes }, format: :json },
          -> { delete :destroy, params: { objective_id: objective.id, id: level.id }, format: :json},
          -> { put :update_order, params: { objective_id: objective.id, level_ids: [level.id] }, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
