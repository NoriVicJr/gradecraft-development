describe LearningObjectiveLevel do
  describe "validations" do
    let(:yellow_level) { build_stubbed :learning_objective_level, :flagged_yellow }

    it "require a name" do
      yellow_level.name = nil
      expect(yellow_level).to be_invalid
    end

    it "require an objective" do
      yellow_level.objective = nil
      expect(yellow_level).to be_invalid
    end

    it "require a flagged value" do
      expect(build_stubbed :learning_objective_level).to be_invalid
    end

    it "permit only allowable values" do
      expect{ yellow_level.flagged_value = :azure }.to raise_error \
        ArgumentError, "'azure' is not a valid flagged_value"
    end
  end
end
