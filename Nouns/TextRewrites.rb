class TextRewrites

	attr_accessor :case_sensitive, :id, :preserve_first_letter_case, :text_match, :text_replace

	def initialize(data=nil)
		json_obj = Validator::validate_argument(data,'TextRewrites')
		@case_sensitive = json_obj['case_sensitive']
		@id = json_obj['id']
		@preserve_first_letter_case = json_obj['preserve_first_letter_case']
		@text_match = json_obj['text_match']
		@text_replace = json_obj['text_replace']
	end

	def json
		json_data = Hash.new
		json_data[:case_sensitive] = @case_sensitive   	                      unless @case_sensitive.nil?
		json_data[:id] = @id                                				  unless @id.nil?
		json_data[:preserve_first_letter_case] = @preserve_first_letter_case  unless @preserve_first_letter_case.nil?
		json_data[:text_match] = @text_match                                  unless @text_match.nil?
		json_data[:text_replace] = @text_replace                              unless @text_replace.nil?

		return json_data	
	end

end