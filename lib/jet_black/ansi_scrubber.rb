# frozen_string_literal: true

module JetBlack
  class AnsiScrubber
    ESCAPE_SEQUENCE = /
      \x1B # ESC char - start of the sequence
      (
        [\x20-\x2F]*
        [\x40-\x5A\x5C-\x7E]
        |
        \[           # Start CSI sequence
        [\x30-\x3F]+ # CSI Parameter bytes
        [\x20-\x2F]* # CSI Intermediate bytes
        [\x40-\x7E]  # CSI Finishing byte
      )
    /x

    def self.call(string)
      string.gsub(ESCAPE_SEQUENCE, "")
    end
  end
end
