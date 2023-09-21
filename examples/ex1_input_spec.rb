require_relative "rails_helper"

RSpec.describe MyModel, type: :model do
  subject(:model) { described_class.new }

  it { is_expected.to validate_presence_of(:name) }

  it "should allow integer values for age" do
    model.age = 1
    expect(model.age).to eq 1
  end

  it "should allow string values for name" do
    model.name = "test"
    expect(model.name).to eq "test"
  end

  it "should be invalid with invalid name" do
    model.name = nil
    expect(model).to be_invalid
  end

  it "should convert integer values for name" do
    model.name = 1
    expect(model.name).to eq "1"
  end

  it "should not allow string values for age" do
    model.age = "test"
    expect(model.age).to eq 0
  end
end
