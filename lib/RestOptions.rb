require 'erb'
require 'colorize'

require_relative 'MyLogger'

class RestOptions

    include Logging

    # @!parse attr_reader :options
    attr_reader :options

    # Creates new RestOptions object
    #
    # @return [RestClient object]
    #
    # @example 
    #         options = RestOptions.new
    def initialize
        @options = ''
    end

    private
    #Designed to handle single values and arrays of values ("john, joe , , jim,") => "john,joe,jim"
    # @!visibility private
    def clean(value)
        str = nil
        if value.is_a?(String) || value.is_a?(Integer)
            str_array = value.to_s.split(',') #spilt it
            str_array = str_array.uniq     #remove duplicates    
            str_array = str_array.reject {|value| value.strip.length == 0} #remove empty values
            str       = str_array.join(',') # rebuild string 
        elsif value.is_a?(Array)
            #make sure only Integers or Strings are in the Array
            value.each do |val|
                unless val.is_a?(String) || val.is_a?(Integer)
                    msg = "Error: Invalid value detected in RestOptions argument. Expected a String, " +
                          "Integer, or Array of Strings and/or Integers.\nInstead got a(n) => #{val.class} " +
                          "at index #{value.find_index(val)} ...Exiting"
                    logger.error(msg.red)
                    abort
                end
            end
            #build clean string from array
            str_array = value.map { |val| val.to_s.strip }       # Trim whitespace from each element
            str_array = str_array.reject { |val| val.eql?('')}  # Remove any empty strings 
            str = str_array.join(',').gsub(/[\[\]]/,'')          # Turn array into string and remove the braces '[]' bc it causes 
        end                                                      # the first result of the generated query to not be returned by the server
        return str                                               # The ERB::Util.url_encode turns braces '[]' into %5b and %5D respectively instead of ignoring them
    end

    public
    # Add search critieria to http query string
    #
    # @param field_name [string] Query field name (Required)
    # @param field_value [string] Query field value (Required)
    # @return [nil]
    #
    # @example 
    #         options.add_option('name','jim') => ?name=jim
    #          options.add_option('limit','100') => ?name=jim&limit=100
    def add_option(field_name,field_value)
        field = clean(field_name)
        value = clean(field_value)
        if field && value && @options.empty?
            @options += '?' + field + '=' + ERB::Util.url_encode(value)
        elsif field && value && !@options.empty?
            @options += '&' + field + '=' + ERB::Util.url_encode(value)
        end
    end    

    # Remove search critieria to http query string
    #
    # @param field_name [string] Query field name (Required)
    # @param field_value [string] Query field value (Required)
    # @return [nil]
    #
    # @example 
    #         options.remove_option('name','jim')
    def remove_option(field_name,field_value)
        value = clean(field_name) + '=' + ERB::Util.url_encode(clean(field_value))
        unless @options.empty?
            if @options.include?("?#{value}")
                @options.gsub!("?#{value}",'')
            elsif @options.include?("&#{value}")
                @options.gsub!("&#{value}",'')
            else
                msg = "\"#{field_name}=#{field_value}\" parameter not found. Nothing to remove." 
                logger.info(msg)
            end
        end
    end

    # Remove all search critieria to http query string. Alias to clear_options method
    #
    # @return [nil]
    #
    # @example 
    #         options.clear()
    def clear
        @options = ''
    end

    # Remove all search critieria to http query string
    #
    # @return [nil]
    #
    # @example 
    #         options.clear_options()
    def clear_options
        clear
    end

    # @!visibility private
    def get_options
        @options
    end

end