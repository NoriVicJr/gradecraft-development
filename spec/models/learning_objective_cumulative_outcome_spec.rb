describe LearningObjectiveCumulativeOutcome do
  let(:user) { build :user }
  let(:cumulative_outcome) { build :learning_objective_cumulative_outcome, user: user }

  describe "validations" do
    it "require a user" do
      cumulative_outcome.user = nil
      expect(cumulative_outcome).to be_invalid
    end

    it "ensure that a user can have only one cumulative outcome" do
      outcome = create :learning_objective_cumulative_outcome, user: user
      expect{ create :learning_objective_cumulative_outcome, user: user,
        learning_objective: outcome.learning_objective }.to raise_error \
          ActiveRecord::RecordInvalid, /should be unique per learning objective/
    end
  end
end
