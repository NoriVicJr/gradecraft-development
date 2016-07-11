require "export"
require "s3_manager"
require "active_record_spec_helper"

describe CourseAnalyticsExport do
  subject { create :course_analytics_export, course_id: course.id }
  let(:course) { create :course }

  it "includes S3Manager::Rescource" do
    expect(subject).to respond_to :stream_s3_object_body
    expect(subject).to respond_to :rebuild_s3_object_key
  end

  it "includes Export::Model::ActiveRecord" do
    expect(subject).to respond_to :created_at_in_microseconds
  end

  describe "#s3_object_key_prefix" do
    before do
      allow(subject).to receive_messages \
        created_at_date: "some-date",
        created_at_in_microseconds: "12345"
    end

    it "builds a path for the s3 object" do
      expect(subject.s3_object_key_prefix).to eq \
        "exports/courses/#{course.id}/course_analytics_exports/some-date/12345"
    end
  end

  describe "#destroy" do
    context "after success" do
      it "removes the object from s3" do
        pending
      end
    end
  end
end
