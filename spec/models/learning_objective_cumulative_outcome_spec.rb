describe LearningObjectiveCumulativeOutcome do
  let(:user) { build :user }
  let(:cumulative_outcome) { build :learning_objective_cumulative_outcome, user: user }
  let(:flagged_red_level) { build :learning_objective_level, :flagged_red }
  let(:red_observed_outcome) do
    create :learning_objective_observed_outcome,
      learning_objective_level: flagged_red_level,
      cumulative_outcome: cumulative_outcome
  end

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

  describe "#failed?" do
    it "returns true if there is a learning objective outcome that is flagged red" do
      red_observed_outcome
      expect(cumulative_outcome).to be_failed
    end
  end

  describe "#status" do
    let(:learning_objective) { cumulative_outcome.learning_objective }
    let(:flagged_yellow_level) { build :learning_objective_level, :flagged_yellow }

    it "returns 'Failed' if the outcome failed" do
      red_observed_outcome
      expect(cumulative_outcome.status).to eq "Failed"
    end

    it "returns 'In progress' if the count to achieve has not yet been met" do
      learning_objective.count_to_achieve = 2
      create :learning_objective_observed_outcome,
        learning_objective_level: flagged_yellow_level,
        cumulative_outcome: cumulative_outcome
      expect(cumulative_outcome.status).to eq "In progress"
    end

    it "returns 'Completed' if the count to achieve has been met" do
      learning_objective.count_to_achieve = 2
      create_list :learning_objective_observed_outcome, 2,
        learning_objective_level: flagged_yellow_level,
        cumulative_outcome: cumulative_outcome
      expect(cumulative_outcome.status).to eq "Completed"
    end
  end
end
