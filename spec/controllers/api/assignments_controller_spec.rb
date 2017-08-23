include SessionHelper

describe API::AssignmentsController do
  let(:course) { build_stubbed :course, status: true }
  let(:student)  { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let!(:assignment) { create(:assignment, course: course) }
  let!(:predicted_earned_grade) { create :predicted_earned_grade, student: student, assignment: assignment }
  let!(:grade) { create :grade, student: student, assignment: assignment }

  context "as professor" do
    before do
      login_user(professor)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(professor)
    end

    describe "GET index" do
      it "assigns assignments, no grade or student" do
        get :index, format: :json
        expect(assigns(:assignments).first.id).to eq(assignment.id)
        expect(assigns :student).to be_nil
        expect(assigns :predicted_earned_grades).to be_nil
        expect(assigns :grades).to be_nil
        expect(response).to render_template(:index)
      end

      describe "ordered by position" do
        it "orders primarily by postions and secondarily by assignment type position" do
          assignment.assignment_type.update(position: 2)
          at2 = create :assignment_type, position: 1, course: course

          a2 = create :assignment, position: 1, assignment_type: at2, course: course
          a3 = create :assignment, position: 1, assignment_type: assignment.assignment_type, course: course
          a4 = create :assignment, position: 2, assignment_type: at2, course: course
          assignment.update(position: 5)
          get :index, format: :json
          expect(assigns(:assignments).pluck(:position)).to eq([1,1,2,5])
          expect(assigns(:assignments).pluck(:id)).to eq([a2.id, a3.id, a4.id, assignment.id])
        end
      end
    end

    describe "GET show" do
      it "assigns the assignment" do
        get :show, params: { id: assignment.id }, format: :json
        expect(assigns(:assignment).id).to eq(assignment.id)
        expect(response).to render_template(:show)
      end
    end

    describe "PUT update" do
      it "updates boolean attributes from params" do
        expect(assignment.visible).to be_truthy
        post :update, params: {
          id: assignment.id, assignment: { visible: false}}, format: :json
        assignment.reload
        expect(assignment.visible).to be_falsey
      end

      it "creates learning objective links" do
        create :learning_objective
        assignment_params = attributes_for(:assignment).merge(learning_objective_links_attributes: [{ objective_id: 1 }])

        expect{ post :update, params: { assignment: assignment_params, id: assignment.id }, format: :json }.to \
          change(LearningObjectiveLink, :count).by 1
      end
    end

    describe "POST sort" do
      it "sorts the assignments by params" do
        second_assignment = create(:assignment, assignment_type: assignment.assignment_type)
        course.assignments << second_assignment

        post :sort, params: { assignment: [second_assignment.id, assignment.id] }

        expect(assignment.reload.position).to eq(2)
        expect(second_assignment.reload.position).to eq(1)
      end
    end
  end

  context "as student" do
    before do
      login_user(student)
      allow(controller).to receive(:current_course).and_return(course)
      allow(controller).to receive(:current_user).and_return(student)
    end

    describe "GET index" do
      context "when the course is active" do
        it "assigns the assignments with predictions and grades and a call to update" do
          get :index, format: :json
          expect(assigns(:assignments).first.id).to eq(assignment.id)
          expect(assigns :student).to eq(student)
          expect(assigns :predicted_earned_grades).to eq([predicted_earned_grade])
          expect(assigns :grades).to eq([grade])
          expect(assigns(:allow_updates)).to be_truthy
          expect(response).to render_template(:index)
        end
      end

      context "when the course is not active" do
        it "assigns the assignments with predictions and grades and a call to update" do
          course.status = false
          get :index, format: :json
          expect(assigns :student).to eq(student)
          expect(assigns :predicted_earned_grades).to eq([predicted_earned_grade])
          expect(assigns :grades).to eq([grade])
          expect(assigns(:allow_updates)).to be_falsey
          expect(response).to render_template(:index)
        end
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
      it "assigns the assignments with grades, no predictions and no call to update" do
        get :index, format: :json
        expect(assigns(:assignments).first.id).to eq(assignment.id)
        expect(assigns :student).to eq(student)
        expect(assigns :predicted_earned_grades).to be_nil
        expect(assigns :grades).to eq([grade])
        expect(assigns(:allow_updates)).to be_falsey
        expect(response).to render_template(:index)
      end
    end
  end
end
