require 'proctor'

describe Proctor::Override do
  it "inherits from Proctor::Condition" do
    expect(described_class.superclass).to eq Proctor::Condition
  end
end
