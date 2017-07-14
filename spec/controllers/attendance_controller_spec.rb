describe AttendanceController do
  let(:course) { build :course }
  let(:assignment_type) { create :assignment_type, :attendance, course: course }

  before(:each) do
    login_user user
    allow(controller).to receive(:current_course).and_return course
  end

  context "as a professor" do
    let(:user) { build_stubbed :user, courses: [course], role: :professor }

    describe "GET #index" do
      it "redirects to setup when there are no attendance assignments" do
        get :index
        expect(response).to redirect_to action: :setup
      end

      it "assigns the attendance type assignments when they exist" do
        attendance_assignment = create :assignment, assignment_type: assignment_type, course: course
        get :index
        expect(response).to_not have_http_status :redirect
        expect(assigns(:assignments)).to eq [attendance_assignment]
      end
    end

    describe "GET #new" do
      it "assigns a new assignment" do
        get :new
        expect(assigns(:assignment)).to be_a_new Assignment
      end

      it "assigns the attendance type when it exists" do
        create :assignment, assignment_type: assignment_type, course: course
        get :new
        expect(assigns(:assignment_type)).to eq assignment_type
      end

      it "creates an attendance type if it does not exist" do
        expect{ get :new }.to change{ AssignmentType.count }.by 1
        expect(assigns(:assignment_type)).to eq AssignmentType.unscoped.last
      end
    end

    describe "POST create" do
      let(:params) { attributes_for(:assignment).merge assignment_type_id: assignment_type.id }

      it "creates a new assignment" do
        expect{ post :create, params: { assignment: params }}.to \
          change(Assignment, :count).by 1
      end

      it "redirects to index if successful" do
        post :create, params: { assignment: params }
        expect(response).to redirect_to action: :index
      end

      it "renders new if unsuccessful" do
        post :create, params: { assignment: params.except(:assignment_type_id) }
        expect(response).to render_template :new
      end
    end

    describe "POST #setup" do
      it "redirects to index if there are already existing attendance assignments" do
        create :assignment, assignment_type: assignment_type, course: course
        post :setup
        expect(response).to redirect_to action: :index
      end

      it "assigns the attendance type if there are no attendance assignments" do
        post :setup
        expect(assigns(:assignment_type)).to_not be_nil
      end
    end
  end

  context "as a student" do
    let(:user) { build_stubbed :user, courses: [course], role: :student }

    describe "GET #index" do
      it "redirects to dashboard if there are no attendance assignments" do
        get :index
        expect(response).to redirect_to dashboard_path
      end

      it "renders the assignment index" do
        create :assignment, assignment_type: assignment_type, course: course
        get :index
        expect(response).to render_template "assignments/index"
      end
    end

    describe "protected routes" do
      it "return a redirect status" do
        [
          -> { get :new },
          -> { post :setup }
        ].each do |protected_route|
          expect(protected_route.call).to have_http_status :redirect
        end
      end
    end
  end
end
