require "active_record_spec_helper"
require "toolkits/models/shared/files"
require "toolkits/historical_toolkit"

describe SubmissionFile do
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment) }
  let(:student) { build(:user, last_name: "de Kooning", first_name: "Willem") }
  let(:submission) { build(:submission, course: course, assignment: assignment, student: student) }
  let(:submission_file) { submission.submission_files.last }
  let(:new_submission_file) { submission.submission_files.new image_file_attrs }

  extend Toolkits::Models::Shared::Files
  define_context # pull in attrs for image and text files

  subject { new_submission_file }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a filename" do
      subject.filename = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:filename]).to include "can't be blank"
    end
  end

  it_behaves_like "a historical model", :submission_file, filename: "my_submission.doc"

  describe "scopes" do
    let(:unconfirmed_file) { create(:submission_file, last_confirmed_at: nil) }
    let(:confirmed_file) { create(:submission_file, last_confirmed_at: Time.now) }
    let(:confirmed_and_missing) { create(:submission_file, file_missing: true, last_confirmed_at: Time.now) }
    let(:missing_file) { create(:submission_file, file_missing: true) }
    let(:present_file) { create(:submission_file, file_missing: false) }
    before { unconfirmed_file; confirmed_file; missing_file; present_file; confirmed_and_missing }

    describe "unconfirmed" do
      subject { SubmissionFile.unconfirmed }
      it "returns submission files with null last_confirmed_at dates" do
        expect(subject).to include(unconfirmed_file)
      end

      it "doesn't return submission files with last_confirmed_at dates" do
        expect(subject).not_to include(confirmed_file)
      end
    end

    describe "confirmed" do
      subject { SubmissionFile.confirmed }
      it "returns submission files where last_confirmed_at is not null" do
        expect(subject).to include(confirmed_file)
      end

      it "returns submission files with null last_confirmed_at dates" do
        expect(subject).not_to include(unconfirmed_file)
      end
    end

    describe "missing" do
      subject { SubmissionFile.missing }
      it "returns submission files where the file is missing" do
        expect(subject).to include(missing_file)
      end

      it "doesn't return submission files where the file is present" do
        expect(subject).not_to include(present_file)
      end
    end

    describe "present" do
      subject { SubmissionFile.present }
      it "returns submission files where the file is not missing" do
        expect(subject).to include(present_file)
      end

      it "doesn't return submission files where the file is missing" do
        expect(subject).not_to include(missing_file)
      end
    end
  end

  describe "versioning", versioning: true do
    before { subject.save }

    it "is enabled for submissions" do
      expect(PaperTrail).to be_enabled
    end

    it "is versioned" do
      expect(subject).to be_versioned
    end
  end

  describe "#course" do
    it "returns the course associated with the submission" do
      expect(subject.course).to eq(course)
    end
  end

  describe "#assignment" do
    it "returns the assignment associated with the submission" do
      expect(subject.assignment).to eq(assignment)
    end
  end

  describe "#owner_name" do
    it "returns the formatted student name associated with the submission" do
      expect(subject.owner_name).to eq("#{student.last_name}-#{student.first_name}")
    end

    it "returns the group name associated with a group submission" do
      group = build(:group, name: "Group Name")
      group_assignment = build(:assignment, grade_scope: "Group")
      group_submission = build(:submission, course: course, assignment: group_assignment, group: group)
      group_file = group_submission.submission_files.new image_file_attrs
      expect(group_file.owner_name).to eq("Group-Name")
    end
  end

  describe "extension", inspect: true do
    subject { submission_file.extension }
    let(:submission_file) { build(:submission_file, filename: "garrett_went_to_town.ppt") }

    it "gets the extension from the filename" do
      expect(subject).to eq(".ppt")
    end
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      subject.submission.save!
      expect(subject.submission_id).to equal submission.id
      expect(subject.new_record?).to be_falsey
    end

    it "is deleted when the parent submission is destroyed" do
      subject.submission.save!
      expect {submission.destroy}.to change(SubmissionFile, :count).by(-1)
    end
  end

  describe "uploading multiple files" do
    it "accepts multiple files" do
      submission.submission_files.new text_file_attrs.merge(filepath: 'uploads/submission_file/')
      subject.submission.save!
      expect(submission.submission_files.count).to equal 2
    end
  end

  describe "formatting name of mounted file" do
    subject { new_submission_file.read_attribute(:file) }
    let(:save_submission) { new_submission_file.submission.save! }

    it "accepts text files as well as images" do
      new_submission_file.file = fixture_file('test_file.txt', 'txt')
      save_submission
      expect expect(subject).to match(/\d+_test_file\.txt/)
    end

    it "has an accessible url" do
      save_submission
      expect expect(subject).to match(/\d+_test_image\.jpg/)
    end

    it "shortens and removes non-word characters from file names on save" do
      new_submission_file.file = fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')
      save_submission
      expect(subject).to match(/\d+_too_long__strange_characters__and_spaces_\.jpg/)
    end
  end

  describe "url" do
    subject { new_submission_file.url }
    before { allow(new_submission_file).to receive_message_chain(:s3_object, :presigned_url) { "http://some.url" }}

    it "returns the presigned amazon url" do
      expect(subject).to eq("http://some.url")
    end
  end

  describe "S3Manager::Carrierwave inclusion" do
    let(:submission_file) { build(:submission_file) }

    it "can be deleted from s3" do
      expect(submission_file.respond_to?(:delete_from_s3)).to be_truthy
    end

    it "can check whether it exists on s3" do
      expect(submission_file.respond_to?(:exists_on_s3?)).to be_truthy
    end
  end
end
