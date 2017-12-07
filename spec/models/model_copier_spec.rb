describe ModelCopier do
  let(:model) { create :course }

  describe "#initialize" do
    it "initializes with the model you want to copy" do
      expect(described_class.new(model).original).to eq model
    end
  end

  describe "#copy" do
    context "with no additional params" do
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

      before(:each) { create :badge, course: model }

      it "copies the associations" do
        subject = described_class.new(model).copy associations: :badges
        expect(subject.badges.count).to eq 1
        expect(subject.badges.map(&:course_id).uniq).to eq [subject.id]
      end

      context "with association attributes" do
        subject { described_class.new(model).copy associations: [assignment_types: { course_id: :id }] }

        before(:each) do
          assignment_type = create :assignment_type, course: model
          create :assignment, assignment_type: assignment_type, course: model
        end

        it "copies the associations with the attributes" do
          expect(subject.assignment_types.count).to eq 1
          expect(subject.assignment_types.map(&:course_id).uniq).to eq [subject.id]
          expect(subject.assignments.map(&:course_id)).to eq [subject.id]
        end
      end
    end

    context "with lookups" do

      # use level badge as an test example,
      # since it has two associated model ids we can test.
      let(:original) { create :level_badge }
      let(:lookup_store) { ModelCopierLookups.new }

      context "when id is found" do
        before do
          allow(lookup_store).to receive(:lookup_hash).and_return({
            badges: { original.badge_id => 1234 },
            levels: { original.level_id => 5678 }
          })
        end

        it "copies the ids from the lookup_store" do
          copied = described_class.new(original, lookup_store).copy options: { lookups: [:badges, :levels] }
          expect(copied.badge_id).to eq(1234)
          expect(copied.level_id).to eq(5678)
        end
      end

      context "when the id is not present" do
        it "defaults to the original id" do
          copied = described_class.new(original, lookup_store).copy options: { lookups: [:badges, :levels] }
          expect(copied.level_id).to eq(original.level_id)
        end
      end
    end
  end

  describe ModelCopier::AssociationAttributeParser do
    describe "#split_attributes_from_association" do
      it "stores the attributes hash, parsed from the associations" do
        subject = described_class.new(assignment_types: { course_id: :id, name: :name })
        expect(subject.attributes).to be_nil
        expect(subject.split_attributes_from_association).to eq({ course_id: :id, name: :name })
        expect(subject.attributes).to eq({ course_id: :id, name: :name })
      end
    end

    describe "#assign_values_to_attributes" do
      it "pulls the attribute from the target and replaces the key in the hash" do
        subject = described_class.new(assignment_types: { course_id: :id, name: :name })
        subject.split_attributes_from_association
        expect(subject.attributes).to eq({ course_id: :id, name: :name })
        subject.assign_values_to_attributes(double :course, id: 555, name: "frootloops")
        expect(subject.attributes).to eq(course_id: 555, name: "frootloops")
      end
    end
  end

  describe "ModelCopierLookups" do
    let!(:badge) { create :badge, course: model }

    it "sets a lookup when a model is copied" do
      lookup_store = ModelCopierLookups.new
      copied = described_class.new(model, lookup_store).copy associations: :badges
      expect(lookup_store.lookup(:courses, model.id)).to eq copied.id
      expect(lookup_store.lookup(:badges, badge.id)).to eq copied.badges.first.id
    end

    it "returns a hash of lookup_store from the original" do
      lookup_store = ModelCopierLookups.new
      copied = described_class.new(model, lookup_store).copy associations: :badges
      expect(lookup_store.assign_values_to_attributes([:courses], badge )).to eq({course_id: copied.id})
    end
  end
end
