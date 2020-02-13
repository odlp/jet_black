# frozen_string_literal: true

require "jet_black/ansi_scrubber"

RSpec.describe JetBlack::AnsiScrubber do
  subject { described_class }

  it "scrubs colors" do
    string = "This is \e[33mGreen\e[0m"

    expect(subject.call(string)).to eq "This is Green"
  end

  it "scrubs colors from multi-line text" do
    string = "This is\n\e[33mGreen\e[25m"

    expect(subject.call(string)).to eq "This is\nGreen"
  end

  it "scrubs escapes" do
    string = "Contains \e~ an escape ending in tilde"

    expect(subject.call(string)).to eq "Contains  an escape ending in tilde"
  end

  it "scrubs escapes with intermediate characters" do
    string = "Contains \e$~ an escape ending in tilde"

    expect(subject.call(string)).to eq "Contains  an escape ending in tilde"
  end

  it "scrubs escapes with non-ASCII characters" do
    string = "ジェット\e[33m黒"

    expect(subject.call(string)).to eq "ジェット黒"
  end
end
