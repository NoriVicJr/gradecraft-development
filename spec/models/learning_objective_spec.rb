describe LearningObjective do
  describe "validations" do
    let(:objective) { build_stubbed :learning_objective }
    let(:objective_for_category) { build_stubbed :learning_objective, :for_category}

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
      another_course = build :course
      objective_for_category.course = another_course
      expect(objective).to be_invalid
    end
  end
end
