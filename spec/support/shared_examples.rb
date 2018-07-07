shared_examples_for('a json builder') do
    describe '#json' do
        it 'converts object to json' do
            expect(subject.json.is_a?(Hash)).to be true
        end
    end
end