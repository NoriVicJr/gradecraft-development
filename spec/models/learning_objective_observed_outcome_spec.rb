describe LearningObjectiveObservedOutcome do
  describe "validations" do
    let(:outcome) { build_stubbed :learning_objective_observed_outcome_grade }

    it "require an assessed at date" do
      outcome.assessed_at = nil
      expect(outcome).to be_invalid
    end

    it "require an objective level" do
      outcome.objective_level = nil
      expect(outcome).to be_invalid
    end
  end
end
