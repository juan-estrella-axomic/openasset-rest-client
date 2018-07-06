require_relative '../JsonBuilder'
class TextRewrites
    include JsonBuilder
    # @!parse attr_accessor :case_sensitive, :id, :preserve_first_letter_case, :text_match, :text_replace
    attr_accessor :case_sensitive, :id, :preserve_first_letter_case, :text_match, :text_replace

    # Creates a TextRewrites object (Only Permits GET requests)
    #
    # @param data [ Hash or nil ] Default => nil
    # @return [TextRewrites object]
    #
    # @example
    #         text_rewrite = TextRewrites.new
    def initialize(data=nil)
        json_obj = Validator::validate_argument(data,'TextRewrites')
        @case_sensitive = json_obj['case_sensitive']
        @id = json_obj['id']
        @preserve_first_letter_case = json_obj['preserve_first_letter_case']
        @text_match = json_obj['text_match']
        @text_replace = json_obj['text_replace']
    end
end