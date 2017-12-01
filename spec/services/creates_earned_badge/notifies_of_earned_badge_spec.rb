describe Services::Actions::NotifiesOfEarnedBadge do
  let(:course) { create :course }
  let(:delivery) { double(:email, deliver_now: nil) }
  let!(:student) { create(:course_membership, :student, course: course).user }
  let!(:earned_badge) { create :earned_badge, student: student, awarded_by: user, course: course }
  let(:user) { create :user }

  it "expects an earned badge to send the notification about" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "when set to notify" do
    let(:context) { { earned_badge: earned_badge, notify: true } }

    context "with a badge that is student visible" do
      it "sends a notification to the student of the newly awarded badge" do
        expect(delivery).to receive(:deliver_now)
        expect(NotificationMailer).to \
          receive(:earned_badge_awarded).with(earned_badge).and_return delivery
        described_class.execute context
      end

      it "creates an announcement for the student" do
        allow(NotificationMailer).to receive(:earned_badge_awarded).and_return delivery

        expect { described_class.execute context }.to \
          change { Announcement.count }.by 1
      end
    end

    context "with a badge that is not student visible" do
      before { earned_badge.update_attributes(grade: (create :in_progress_grade)) }

      it "does not send the notification" do
        expect(NotificationMailer).to_not receive(:earned_badge_awarded)
        described_class.execute context
      end

      it "does not create an announcement for the student" do
        expect { described_class.execute context }.to_not \
          change { Announcement.count }
      end
    end
  end

  context "when not set to notify" do
    let(:context) { { earned_badge: earned_badge, notify: false } }
    
    it "does not send the notification" do
      expect(NotificationMailer).to_not receive(:earned_badge_awarded)
      described_class.execute context
    end

    it "does not create an announcement for the student" do
      expect { described_class.execute context }.to_not \
        change { Announcement.count }
    end
  end
end
