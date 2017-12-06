describe LevelBadge do
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
        copied_course = level_badge.badge.course.copy(nil)
        copy = LevelBadge.last
        expect(copy.badge.course).to eq(copied_course)
        expect(copy.level.criterion.rubric.course).to eq(copied_course)
      end
    end
  end
end

