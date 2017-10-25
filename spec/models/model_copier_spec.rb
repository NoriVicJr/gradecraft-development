describe ModelCopier do
  let(:model) { create :course }

  describe "#initialize" do
    it "initializes with the model you want to copy" do
      expect(described_class.new(model).original).to eq model
    end
  end

  describe "#copy" do
    subject { described_class.new(model).copy }

    it "duplicates the model" do
      expect(subject).to be_an_instance_of model.class
      expect(subject.object_id).to_not eq model.object_id
    end

    it "duplicates the attributes" do
      model.course_number = "BLAH"

      expect(subject.course_number).to eq "BLAH"
    end

    it "saves the duplicated model" do
      expect(subject).to be_persisted
    end

    it "does not save the duplicated model if the model is not saved" do
      subject = build model.class.name.underscore.to_sym

      expect(subject).to_not be_persisted
    end

    context "with prepend option" do
      it "prepends the specified attribute with the specified text" do
        name = model.name
        subject = described_class.new(model).copy options: { prepend: { name: "Copy of " }}

        expect(subject.name).to eq "Copy of #{name}"
      end
    end

    context "with overrides option" do
      it "runs the overrides" do
        subject = described_class.new(model).copy options: { overrides: [->(copy) { copy.name = "Blah" }]}

        expect(subject.name).to eq "Blah"
      end
    end

    context "with attributes" do
      it "copies the attribute values" do
        model.course_number = "BLAH"
        subject = described_class.new(model).copy attributes: { course_number: "BLEH" }

        expect(subject.course_number).to eq "BLEH"
      end
    end

    context "with an association to copy" do
      subject { described_class.new(model).copy associations: :badges }

      before(:each) { create :badge, course: model }

      it "copies the associations" do
        expect(subject.badges.count).to eq 1
        expect(subject.badges.map(&:course_id).uniq).to eq [subject.id]
      end

      context "with association attributes" do
        subject { described_class.new(model).copy associations: [assignment_types: { course_id: :id }] }

        before(:each) do
          assignment_type = create :assignment_type, course: model
          create :assignment, assignment_type: assignment_type
        end

        it "copies the associations with the attributes" do
          expect(subject.assignment_types.count).to eq 1
          expect(subject.assignment_types.map(&:course_id).uniq).to eq [subject.id]
          expect(subject.assignments.map(&:course_id)).to eq [subject.id]
        end
      end
    end
  end

  describe "lookups" do
    before(:each) { create :badge, course: model }

    it "sets a lookup when a model is copied" do
      lookups = ModelCopierLookups.new
      copied = described_class.new(model, lookups).copy associations: :badges
      expect(lookups.lookup(:course, model.id)).to eq copied.id
      expect(lookups.lookup(:badge, model.badges.first.id)).to eq copied.badges.first.id
    end
  end
end
