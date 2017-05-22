class NestedSizeItems
    
    attr_accessor :width, :cropped, :watermarked, :relative_path, :y_resolution, :allow_use
    attr_accessor :id, :http_relative_path, :quality, :unc_root, :colourspace, :height
    attr_accessor :http_root, :x_resolution, :filesize, :recreate, :file_format

    def initialize(data=nil)

        json_obj = Validator::validate_argument(data,'NestedSizeItem')

        @width = json_obj['width']
        @cropped = json_obj['cropped']
        @watermarked = json_obj['watermarked']
        @relative_path = json_obj['relative_path']
        @y_resolution = json_obj['y_resolution']
        @allow_use = json_obj['allow_use']
        @id = json_obj['id']
        @http_relative_path = json_obj['http_relative_path']
        @quality = json_obj['quality']
        @unc_root = json_obj['unc_root']
        @colourspace = json_obj['colourspace']
        @height = json_obj['height']
        @http_root = json_obj['http_root']
        @x_resolution = json_obj['x_resolution']
        @filesize = json_obj['filesize']
        @recreate = json_obj['recreate']
        @file_format = json_obj['file_format'] 
    end

    def json
        json_data = Hash.new
        json_data[:width] = @width                              unless @width.nil?
        json_data[:cropped] = @cropped                          unless @cropped.nil?
        json_data[:watermarked] = @watermarked                  unless @watermarked.nil?
        json_data[:relative_path] = @relative_path              unless @relative_path.nil?
        json_data[:y_resolution] = @y_resolution                unless @y_resolution.nil?
        json_data[:allow_use] = @allow_use                      unless @allow_use.nil?
        json_data[:id] = @id                                    unless @id.nil?
        json_data[:http_relative_path] = @http_relative_path    unless @http_relative_path.nil?
        json_data[:quality] = @quality                          unless @quality.nil?
        json_data[:unc_root] = @unc_root                        unless @unc_root.nil?
        json_data[:colourspace] = @colourspace                  unless @colourspace.nil?
        json_data[:height] = @height                            unless @height.nil?
        json_data[:http_root] = @http_root                      unless @http_root.nil?
        json_data[:x_resolution] = @x_resolution                unless @x_resolution.nil?
        json_data[:filesize] = @filesize                        unless @filesize.nil?
        json_data[:recreate] = @recreate                        unless @recreate.nil?
        json_data[:file_format] = @file_format                  unless @file_format.nil?

        return json_data
    end
end