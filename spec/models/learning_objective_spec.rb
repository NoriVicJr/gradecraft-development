describe LearningObjective do
  describe "validations" do
    let(:objective) { build_stubbed :learning_objective }
    let(:category) { build_stubbed :learning_objective_category }

    it "require a name" do
      objective.name = nil
      expect(objective).to be_invalid
    end

    it "require a course" do
      objective.course = nil
      expect(objective).to be_invalid
    end

    it "prevent a negative value for the count to achieve" do
      objective.count_to_achieve = -1
      expect(objective).to be_invalid
    end

    it "ensure that the objective course matches the category course when present" do
      objective.category = category
      objective.course = build :course
      expect(objective).to be_invalid
    end
  end
end
