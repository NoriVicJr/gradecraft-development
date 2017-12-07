describe CoursesController do
  include UniMock::StubRails

  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:admin) { create(:course_membership, :admin, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }

  context "as admin" do
    before(:each) { login_user(admin) }

    describe "GET index" do
      it "assigns the variables" do
        get :index
        expect(assigns(:courses)).to eq [course]
        expect(assigns(:can_create_courses)).to be_truthy
      end
    end

    describe "GET new" do
      it "assigns title" do
        get :new
        expect(assigns(:course)).to be_a_new(Course)
        expect(response).to render_template(:new)
      end
    end

    describe "POST create" do
      it "creates the course with valid attributes"  do
        params = attributes_for(:course)
        params[:id] = course
        expect{ post :create, params: { course: params }}.to change(Course,:count).by(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, params: { course: attributes_for(:course, name: nil) }}
          .to_not change(Course,:count)
      end
    end

    describe "POST recalculate_student_scores" do
      it "recalculates student scores" do
        expect_any_instance_of(Course).to receive(:recalculate_student_scores)
        post :recalculate_student_scores, params: { id: course.id.to_s }
      end

      it "redirects to root on success with a notice" do
        post :recalculate_student_scores, params: { id: course.id.to_s }
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to_not be_nil
      end
    end

    describe "POST activate_all_students" do
      let(:unactivated_user) { create(:user)}
      it "activates the user" do
        post :activate_all_students, params:{id: course.id}
        expect(unactivated_user.activated?).to eq true
      end

      it "redirects to referer url if present" do
        request.env["HTTP_REFERER"] = "http://some-referer.com"
        post :activate_all_students, params:{id: course.id}
        expect(response).to redirect_to("http://some-referer.com")
      end

      it "redirects to students_path if referer url is not present" do
        post :activate_all_students, params:{id: course.id}
        expect(response).to redirect_to(students_path)
      end
    end

    describe "POST copy" do
      it "creates a duplicate course" do
        expect{ post :copy, params: { id: course.id }}.to change(Course, :count).by(1)
      end

      it "duplicates badges if present" do
        create(:badge, course: course)
        expect{ post :copy, params: { id: course.id }}.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.badges.present?).to eq(true)
      end

      it "duplicates challenges if present" do
        create(:challenge, course: course)
        expect{ post :copy, params: { id: course.id }}.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.challenges.present?).to eq(true)
      end

      it "duplicates grade_scheme_elements if present" do
        create(:grade_scheme_element, course: course)
        expect{ post :copy, params: { id: course.id }}.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.grade_scheme_elements.present?).to eq(true)
      end

      it "duplicates assignment_types and assignments if present" do
        assignment_type = create(:assignment_type, course: course)
        create(:assignment, assignment_type: assignment_type, course: course)
        expect{ post :copy, params: { id: course.id }}.to change(Course, :count).by(1)
        course_2 = Course.last
        expect(course_2.assignment_types.present?).to eq(true)
        expect(course_2.assignments.present?).to eq(true)
      end

      it "duplicates score levels if present" do
        assignment_type = create(:assignment_type, course: course)
        assignment = create(:assignment, assignment_type: assignment_type, course: course)
        score_level = create(:assignment_score_level, assignment: assignment)
        expect{ post :copy, params: { id: course.id }}.to change(Course, :count).by(1)
        course_2 = Course.last
        assignment_2 = course_2.assignments.first
        expect(assignment_2.assignment_score_levels).to be_present
      end

      it "duplicates rubrics if present" do
        level_badge = create(:level_badge)
        course = level_badge.level.criterion.rubric.course
        create(:course_membership, :professor, course: course, user: admin)
        expect{ post :copy, params: { id: course.id }}.to change(Rubric, :count).by(1)
      end

      it "redirects to the course edit path if the copy fails" do
        course.update_attribute :full_points, "a"
        post :copy, params: { id: course.id }
        expect(response).to redirect_to edit_course_path(Course.unscoped.last)
      end
    end

    describe "POST copy with students" do
      let(:course_with_students) { create(:course_membership, :student, course: course).course }

      it "creates a duplicate course" do
        expect{ post :copy,
                params: { id: course_with_students.id, copy_type: "with_students" }}.to \
        change(Course, :count).by(1)
      end

      it "copies the student" do
        post :copy, params: { id: course_with_students.id, copy_type: "with_students" }
        duplicated = Course.last
        expect(duplicated.students.map(&:id)).to eq course_with_students.students.map(&:id)
      end
    end
  end

  context "as professor" do
    before { login_user(professor) }

    describe "GET index" do
      it "returns all courses the professor has an association with" do
        get :index
        expect(assigns(:courses)).to eq([course])
        expect(response).to render_template(:index)
      end

      it "assigns false for can_create_courses if the environment is beta" do
        stub_env "beta"
        get :index
        expect(assigns(:can_create_courses)).to be_falsey
      end
    end

    describe "GET new" do
      it "redirects to index if the environment is beta" do
        stub_env "beta"
        get :new
        expect(response).to redirect_to action: :index
      end
    end

    describe "POST create" do
      it "redirects to index if the environment is beta" do
        stub_env "beta"
        post :create
        expect(response).to redirect_to action: :index
      end
    end

    describe "GET edit" do
      it "edit title" do
        get :edit, params: { id: course.id }
        expect(assigns(:course)).to eq(course)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST update" do
      it "updates the course" do
        params = { name: "new name" }
        post :update, params: { id: course.id, course: params }
        expect(response).to redirect_to(edit_course_path(id: course.id))
        expect(course.reload.name).to eq("new name")
      end

      it "redirects to the edit path if the course fails to update" do
        params = { name: "" }
        post :update, params: { id: course.id, course: params }
        expect(response).to render_template(:edit)
      end

      it "recalculates scores in the course if add_team_score_to_student changed" do
        params = { add_team_score_to_student: true }
        expect_any_instance_of(Course).to receive(:recalculate_student_scores)
        post :update, params: { id: course.id, course: params }
      end

      it "does not recalculate scores in the course if add_team_score_to_student didn't change" do
        params = { name: "new name" }
        expect_any_instance_of(Course).to_not receive(:recalculate_student_scores)
        post :update, params: { id: course.id, course: params }
      end
    end

    describe "protected routes" do
      it "redirect to root" do
        [
          -> { post :copy },
          -> { post :activate_all_students },
          -> { post :recalculate_student_scores, params: { id: course.id } },
          -> { get :overview }
        ].each do |protected_route|
          expect(protected_route.call).to redirect_to :root
        end
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    describe "GET index" do
      it "returns all courses the student has an association with" do
        get :index
        expect(assigns(:courses)).to eq([course])
        expect(response).to render_template(:index)
      end
    end

    describe "GET change" do
      let(:another_course) { create :course }

      before do
        create(:course_membership, :student, course: another_course, user: student)
        login_user(student)
        session[:course_id] = course.id
        allow(Resque).to receive(:enqueue).and_return(true)
      end

      it "switches the course context" do
        get :change, params: { id: another_course.id }
        expect(response).to redirect_to(root_url)
        expect(session[:course_id]).to eq(another_course.id)
      end

      it "records the course login event if the course changed" do
        expect(subject).to receive(:record_course_login_event)
        get :change, params: { id: another_course.id.to_s }
      end

      it "does not record the course login event if the course does not change" do
        expect(subject).to_not receive(:record_course_login_event)
        get :change, params: { id: course.id.to_s }
      end

      it "stores the course to the current course for the user" do
        get :change, params: { id: another_course.id }
        expect(student.reload.current_course_id).to eq another_course.id
      end
    end

    describe "POST recalculate_student_scores" do
      it "is a protected route" do
        expect(post :recalculate_student_scores, params: { id: course.id.to_s }).to \
          redirect_to(:root)
      end
    end

    describe "protected routes" do
      [
        :new,
        :create,
        :copy
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :activate_all_students
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "1" }).to redirect_to(:root)
        end
      end
    end
  end

  context "as a public user" do
    describe "GET badges" do
      it "returns the public badges show page" do
        get :badges, params: { id: course.id }
        expect(assigns(:course)).to eq(course)
        expect(response).to render_template(:badges)
      end

      it "reroutes to the dashboard if course has public badges turned off" do
        course.has_public_badges = false
        course.save
        get :badges, params: { id: course.id }
        expect(response).to redirect_to root_path
      end
    end
  end
end
