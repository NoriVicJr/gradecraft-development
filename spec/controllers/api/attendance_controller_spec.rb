describe API::AttendanceController do
  let(:course) { build :course }
  let(:assignment_type) { build_stubbed :assignment_type, :attendance }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "#create" do
      let(:assignments_params) { [assignments_attributes_1, assignments_attributes_2] }
      let(:assignments_attributes_1) { attributes_for(:assignment).merge(assignment_type_id: assignment_type.id) }
      let(:assignments_attributes_2) { attributes_for(:assignment).merge(assignment_type_id: assignment_type.id) }

      context "when successful" do
        it "creates the assignments" do
          expect{ post :create, params: { assignments_attributes: assignments_params }, format: :json }.to \
            change(Assignment, :count).by 2
        end

        it "renders the json template" do
          post :create, params: { assignments_attributes: assignments_params }, format: :json
          expect(response).to render_template :create
          expect(response).to have_http_status :ok
        end
      end

      context "when unsuccessful" do
        it "renders a 400 bad request" do
          post :create, format: :json
          expect(response).to have_http_status :bad_request
          expect(response.body).to include "Bad request"
        end
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "protected routes" do
      it "redirect with a status 302" do
        [
          -> { post :create, format: :json }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
