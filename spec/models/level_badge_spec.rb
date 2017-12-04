describe LevelBadge , :focus do
  let(:level_badge) { create :level_badge }

  describe "#copy" do

    it "makes a duplicated copy of itself" do
      subject = level_badge.copy
      expect(subject).to_not eq level_badge
      expect(subject.badge_id).to eq(level_badge.badge_id)
      expect(subject.level_id).to eq(level_badge.level_id)
    end

    context "when copied as part of a course copy" do
      it "uses lookups to assign proper badge and level id" do
        # TODO: create a "proper" level badge where the level and badge belong to the same course
      end
    end
  end
end
