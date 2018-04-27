require "jet_black/rspec"

RSpec.describe "black_box directory" do
  it "adds metadata inferred by spec location" do |example|
    expect(example.metadata[:type]).to eq :black_box
  end

  it "includes the matchers" do
    expect(defined?(have_stdout)).to eq "method"
  end
end
