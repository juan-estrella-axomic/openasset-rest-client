shared_examples_for('a json builder') do
    describe '#json' do
        it 'converts object to json' do
            expect(subject.json.is_a?(Hash)).to be true
        end
        it 'only populates non nil fields' do
            success      = true
            json_obj     = subject.json
            method_names = subject.instance_variables.map { |v| v.to_s.sub(/@/,'').to_sym }
            # Ensure only keys for non-nil values are set
            method_names.each do |method|
                if subject.send(method).nil? && json_obj.has_key?(method)
                    success = false
                    break
                end
            end
            expect(success).to be true
        end
    end
end