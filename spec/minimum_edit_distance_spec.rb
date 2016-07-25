require 'spec_helper'

describe MinimumEditDistance do
  describe "#print_minimal_edits" do
    let(:minimum_edit_distance) { MinimumEditDistance.new(file_1, file_2) }

    subject { minimum_edit_distance.print_minimal_edits }

    shared_examples "correct solution" do
      it 'returns the correct solution' do
        expect {
          subject
        }.to output(
          expected_output(lines)
        ).to_stdout
      end
    end

    def expected_output(lines)
      lines.join("\n") + (lines.empty? ? '' : "\n")
    end

    context 'with blank files' do
      let(:file_1) { [] }
      let(:file_2) { [] }
      let(:lines)  { [] }

      include_examples "correct solution"
    end

    context 'with first blank file' do
      let(:file_1) { [] }
      let(:file_2) { ['aaa', 'bbb', 'ccc'] }
      let(:lines) {
        [
          '1 + aaa',
          '2 + bbb',
          '3 + ccc'
        ]
      }

      include_examples "correct solution"
    end

    context 'with second blank file' do
      let(:file_1) { ['aaa', 'bbb', 'ccc'] }
      let(:file_2) { [] }
      let(:lines) {
        [
          '1 - aaa',
          '2 - bbb',
          '3 - ccc'
        ]
      }

      include_examples "correct solution"
    end

    context 'with not blank files' do
      context 'with added chars' do
        let(:file_1) { ['aaa'] }
        let(:file_2) { ['aaa', 'bbb', 'ccc'] }
        let(:lines) {
          [
            '1   aaa',
            '2 + bbb',
            '3 + ccc'
          ]
        }

        include_examples "correct solution"
      end

      context 'with deleted chars' do
        let(:file_1) { ['aaa', 'bbb', 'ccc'] }
        let(:file_2) { ['aaa'] }
        let(:lines) {
          [
            '1   aaa',
            '2 - bbb',
            '3 - ccc'
          ]
        }

        include_examples "correct solution"
      end

      context 'with replaced chars' do
        let(:file_1) { ['aaa', 'bbb', 'ccc'] }
        let(:file_2) { ['ccc', 'bbb', 'aaa'] }
        let(:lines) {
          [
            '1 * aaa|ccc',
            '2   bbb',
            '3 * ccc|aaa'
          ]
        }

        include_examples "correct solution"
      end

      context 'with added, deleted and replaced chars' do
        let(:file_1) { ['aaa', 'bbb', 'ccc', 'fff'] }
        let(:file_2) { ['aaa', 'ccc', 'ddd', 'eee'] }
        let(:lines) {
          [
            '1   aaa',
            '2 - bbb',
            '3   ccc',
            '4 * fff|ddd',
            '5 + eee',
          ]
        }

        include_examples "correct solution"
      end
    end
  end
end
