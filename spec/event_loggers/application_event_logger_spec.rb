require "active_record_spec_helper"
require "resque_spec/scheduler"

# PageviewEventLogger.new(attrs).enqueue_in(ResqueManager.time_until_next_lull)
RSpec.describe ApplicationEventLogger, type: :event_logger do
  subject { described_class.new }

  let(:course_membership) do
    double(CourseMembership, course: course, user: user, role: "stuff")
  end
  let(:course) { double(Course, id: 20) }
  let(:user) { double(User, id: 30) }

  it "has a queue" do
    expect(described_class.queue).to eq :application_event_logger
  end

  it "has an accessible :event_session attribute" do
    subject.event_session = "waffles"
    expect(subject.event_session).to eq "waffles"
  end

  it "does not include EventLogger::Enqueue" do
    expect(subject).not_to respond_to(:enqueue_in_with_fallback)
  end

  it "has an #event_type" do
    expect(subject.event_type).to eq "application"
  end

  describe "#event_session_user_role" do
    let(:result) { subject.event_session_user_role(event_session) }

    before(:each) do
      allow(subject).to receive(:event_session) { event_session }
    end

    context "event session has a user" do
      let(:event_session) { { user: user, course: course } }
      it "returns the role of the user for the given course" do
        allow(user).to receive(:role).with(course) { course_membership.role }
        expect(result).to eq(course_membership.role)
      end
    end

    context "event session has no user" do
      let(:event_session) { { user: nil } }
      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end

  describe "#application_attrs" do
    let(:student) { double(User, id: 90) }
    let(:event_session) do
      { course: course, user: user, student: student }
    end
    let(:base_attrs) { { great: "scott" } }

    before do
      allow(subject).to receive_messages(
        event_session: event_session,
        event_session_user_role: "jester",
        base_attrs: base_attrs
      )
    end

    it "builds a hash of the event_session data from the controller" do
      expect(subject.application_attrs).to eq({
        course_id: course.id,
        user_id: user.id,
        student_id: student.id,
        user_role: "jester",
      }.merge(base_attrs))
    end

    it "is frozen" do
    end
  end

  describe "#event_attrs" do
    it "returns the #application_attrs" do
      allow(subject).to receive(:application_attrs) { "some-attrs" }
      expect(subject.event_attrs).to eq "some-attrs"
    end
  end

  describe "#params" do
    it "returns event_sessions[:params]" do
      allow(subject).to receive(:event_session) { { params: "param_stuff" } }
      expect(subject.params).to eq("param_stuff")
    end
  end
end
