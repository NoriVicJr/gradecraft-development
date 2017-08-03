describe API::AttendanceController do
  let(:course) { build :course }
  let(:attendance_params) { attributes_for :assignment }
  let(:attendance_event) { create :assignment, assignment_type: assignment_type, course: course }
  let!(:assignment_type) { create :assignment_type, :attendance, course: course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "#index" do
      it "assigns the assignments" do
        attendance_event
        get :index, format: :json

        expect(assigns(:assignments)).to eq [attendance_event]
      end
    end

    describe "#create" do
      context "when successful" do
        it "creates the attendance event" do
          expect{ post :create, params: { assignment: attendance_params }, format: :json }.to \
            change(Assignment, :count).by 1
        end

        it "renders the json template" do
          post :create, params: { assignment: attendance_params }, format: :json

          expect(response).to render_template :show
          expect(response).to have_http_status :created
        end
      end

      context "when unsuccessful" do
        it "renders a 400 bad request" do
          post :create, params: { assignment: attendance_params.except(:name) },
            format: :json

          expect(response).to have_http_status :bad_request
          expect(response.body).to include "Failed to create attendance event"
        end
      end
    end

    describe "#update" do
      context "when successful" do
        it "updates the attendance event" do
          put :update, params: { assignment: attendance_params, id: attendance_event.id },
            format: :json

          expect(attendance_event.reload).to have_attributes attendance_params.slice(:name,
            :description, :open_at, :due_at, :pass_fail)
        end

        it "renders the json template" do
          put :update, params: { assignment: attendance_params, id: attendance_event.id },
            format: :json

          expect(response).to render_template :show
          expect(response).to have_http_status :ok
        end
      end

      context "when unsuccessful" do
        it "renders a 400 bad request" do
          put :update, params: { id: attendance_event.id, assignment: attendance_params.merge(name: nil) },
            format: :json

          expect(response).to have_http_status :bad_request
          expect(response.body).to include "Failed to update attendance event"
        end
      end
    end

    describe "#delete" do
      it "destroys the event" do
        attendance_event

        expect{ delete :destroy, id: attendance_event.id, format: :json }.to \
          change(Assignment, :count).by -1
      end

      it "returns a 200 ok" do
        delete :destroy, params: { id: attendance_event.id }, format: :json

        expect(response).to have_http_status :ok
        expect(response.body).to include "Successfully deleted #{attendance_event.name}"
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { get :index, format: :json },
          -> { post :create, format: :json },
          -> { put :update, format: :json, id: attendance_event.id },
          -> { delete :destroy, format: :json, id: attendance_event.id }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
