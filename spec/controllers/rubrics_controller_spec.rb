describe RubricsController do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let!(:rubric) { create(:rubric_with_criteria, assignment: assignment) }

  context "as a professor" do
    before do
      login_user(professor)
    end

    describe "GET edit" do
      it "shows the design form" do
        get :edit, params: { assignment_id: assignment.id, rubric: rubric}
        expect(response).to render_template(:edit)
      end
    end

    describe "GET export" do
      it "retrieves the export download" do
        get :export, params: { assignment_id: assignment.id }, format: :csv
        expect(response.body).to include("Criteria ID,Criteria Description")
      end
    end

    describe "GET index_for_copy" do
      let(:new_assignment) { create(:assignment, course: course) }

      it "retrieves the list of rubric for course to add" do
        get :index_for_copy, params: { assignment_id: new_assignment.id }
        expect(assigns(:assignment)).to eq(new_assignment)
        expect(assigns(:rubrics)).to eq([rubric])
      end
    end

    describe "GET copy" do
      let(:new_assignment) { create(:assignment, course: course) }
      let(:full_rubric) { create(:rubric_with_criteria) }

      it "copies the full rubric and adds it to the assignment" do
        post :copy, params: { assignment_id: new_assignment.id, rubric_id: full_rubric.id }
        expect(new_assignment.rubric.criteria.pluck(:max_points)).to \
          match_array(full_rubric.criteria.pluck(:max_points))
      end

      it "copies earned badges on rubric" do
        create :dummy_level_badge, level: full_rubric.criteria.first.levels.first
        expect{ post :copy, params: { assignment_id: new_assignment.id, rubric_id: full_rubric.id }}
          .to change(LevelBadge, :count).by(1)
      end

      it "doesn't duplicate badges" do
        create :level_badge, level: full_rubric.criteria.first.levels.first
        expect{ post :copy, params: { assignment_id: new_assignment.id, rubric_id: full_rubric.id }}.to_not change(Badge, :count)
      end
    end
  end

  context "as a student" do
    before { login_user(student) }

    describe "protected routes" do
      [
        :edit,
        :index_for_copy,
        :copy,
        :destroy,
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, params: { assignment_id: 1, id: "1" }).to redirect_to(:root)
          end
        end
    end
  end
end
