describe LearningObjectiveLink do
  describe "validations" do
    let(:link) { build_stubbed :learning_objective_link_assignment }

    it "require a linked objective" do
      link.objective = nil
      expect(link).to be_invalid
    end
  end
end
