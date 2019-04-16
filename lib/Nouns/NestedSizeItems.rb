require_relative '../JsonBuilder'
class NestedSizeItems
    include JsonBuilder
    # @!parse attr_accessor :width, :cropped, :watermarked, :relative_path, :y_resolution, :allow_use
    attr_accessor :width, :cropped, :watermarked, :relative_path, :y_resolution, :allow_use

    # @!parse attr_accessor :id, :http_relative_path, :quality, :unc_root, :colourspace, :height
    attr_accessor :id, :http_relative_path, :quality, :unc_root, :colourspace, :height

    # @!parse attr_accessor :http_root, :x_resolution, :filesize, :recreate, :file_format
    attr_accessor :http_root, :x_resolution, :filesize, :recreate, :file_format

    def initialize(data=nil)

        json_obj = Validator.validate_argument(data,'NestedSizeItem')

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
end