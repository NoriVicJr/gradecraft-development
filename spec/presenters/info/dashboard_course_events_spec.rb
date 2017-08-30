describe Info::DashboardCourseEventsPresenter do
  let(:course) { create(:course) }
  let(:student) { build_stubbed(:user) }
  let(:event) { create :event, course: course }
  let(:event_with_open) { create :event, course: course, open_at: Date.yesterday }
  let(:assignment) { create :assignment, course: course, due_at: event.due_at }

  subject { described_class.new course: course, student: student, assignments: course.assignments }

  describe "#dates_for(event, user)" do
    it "returns the due dates to be displayed for a particular event" do
      expect(subject.dates_for(event, student)).to eq "Due: #{event.due_at.in_time_zone(student.time_zone)}"
    end
    it "returns both the open at and the due at dates to be displayed for a particular event" do
      expect(subject.dates_for(event_with_open, student)).to eq "#{event_with_open.open_at.in_time_zone(student.time_zone)} - #{event_with_open.due_at.in_time_zone(student.time_zone)}"
    end
  end

  describe "#assignments_due_on(event)" do
    it "returns the assignments for the course that are also due on this day" do
      expect(subject.assignments_due_on(event)).to eq [assignment]
    end
  end
end
