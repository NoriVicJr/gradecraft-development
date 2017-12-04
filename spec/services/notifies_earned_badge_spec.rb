require "./app/services/notifies_earned_badge"

describe Services::NotifiesEarnedBadge do
  let(:earned_badge) { build_stubbed :earned_badge }

  describe ".notify" do
    it "notifies for earned badges" do
      expect(Services::Actions::NotifiesOfEarnedBadge).to receive(:execute).and_call_original
      described_class.notify earned_badge
    end
  end
end
