describe LearningObjectiveCategory do
  describe "validations" do
    let(:category) { build_stubbed :learning_objective_category }

    it "require a name" do
      category.name = nil
      expect(category).to be_invalid
    end

    it "require a course" do
      category.course = nil
      expect(category).to be_invalid
    end

    it "prevent a negative value for the allowable number of yellow warnings" do
      category.allowable_yellow_warnings = -1
      expect(category).to be_invalid
    end
  end
end
