require "rails_spec_helper"
require "set"

include ResqueJobSharedExamplesToolkit

RSpec.describe Assignments::GradesController, type: :controller, background_job: true do
  include InQueueHelper
  let(:course) { create(:course_accepting_groups) }
  let(:assignment) { create(:assignment, course_id: course.id) }
  let(:job_attributes) {{ grade_id: grade.id }} # for GradeUpdaterJob calls
  let(:grade_attributes) {{ course_id: course.id, student_id: student.id, assignment_id: assignment.id }}
  let(:grade) { create(:grade, grade_attributes) }

  let(:student) { create(:user) }
  let(:professor) { create(:user) }
  let(:enroll_professor) { CourseMembership.create(user_id: professor.id, course_id: course.id, role: "professor") }

  before(:each) { ResqueSpec.reset! }

  describe "triggering jobs as a professor" do
    before(:each) { enroll_and_login_professor }

    describe "actions that trigger multiple GradeUpdaterJob instances" do
      let(:student2) { create(:user) }
      let(:students) { [student, student2] }
      let(:grade2) { create(:grade, grade_attributes.merge(student_id: student2.id)) }
      let(:grades) { [grade, grade2] }
      let(:grade_ids) { [grade.id, grade2.id] }

      # duplicate this

      describe "PUT #mass_update" do
        before { enroll_and_login_professor }
        let(:request_attrs) {{ assignment_id: assignment.id, assignment: {} }}
        subject { put :mass_update, request_attrs }

        before do
          allow(course).to receive_message_chain(:assignments, :find) { assignment }
          allow(controller).to receive(:mass_update_grade_ids) { grade_ids }
        end

        context "grade attributes are successfully updated" do
          let(:request_attrs) {{ assignment_id: assignment.id,
            id: assignment.id, assignment: {name: "Some Great Name"}}}
          before { allow(assignment).to receive_messages(update_attributes: true) }

          let(:batch_attributes) do
            [{ grade_id: grades.first.id }, { grade_id: grades.last.id }]
          end

          it_behaves_like "a batch of successful resque jobs", 2, GradeUpdaterJob
        end

        context "grade attributes fail to update" do
          # pass an invalid assignment name to fail the update
          # TODO: FIX this, I have no idea why it won't stub
          let(:request_attrs) {{ assignment_id: assignment.id, assignment: { name: nil }}}
          before { allow(assignment).to receive_messages(update_attributes: false) }

          it_behaves_like "a failed resque job", GradeUpdaterJob
        end
      end
    end
  end

  def enroll_and_login_professor
    allow(controller).to receive_messages(current_student: student)
    enroll_professor
    login_user(professor)
    session[:course_id] = course.id
  end
end
