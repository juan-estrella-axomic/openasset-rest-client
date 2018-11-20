module AddFilesToAlbum

    def __add_files_to_album(albums,files)

        expected_albums_args = %w[ String Integer Albums ]
        expected_files_args  = %w[ String Integer Files ]

        albums = albums.is_a?(Array) ? albums : [albums]
        files = files.is_a?(Array) ? files : [files]

        unless expected_albums_args.include?(albums.first)
            logger.error("Expected #{expected_albums_args.inspect} for "\
                         "(argument 1) in #{__callee__} "\
                         "Instead got #{albums.first.inspect}")
            return false
        end

        unless expected_files_args.include?(files.first)
            logger.error("Expected #{expected_files_args.inspect} for "\
                         "(argument 2) in #{__callee__} "\
                         "Instead got #{files.first.inspect}")
            return false
        end

        op = RestOptions.new

        unless albums.first.is_a?(Albums)
            op.add_option('limit', 0)
            op.add_option('id', albums)
            albums = get_albums(op)
            op.clear
            if albums.empty?
                logger.error("Albums with id(s) => #{albums.join(',')} not found.")
                return false
            end
            logger.info("Retrieved album(s).")
        end

        unless files.first.is_a?(Files)
            op.add_option('limit', 0)
            op.add_option('id', files)
            files = get_files(op)
            op.clear
            if files.empty?
                logger.error("Files with id(s) => #{files.join(',')} not found.")
                return false
            end
            logger.info('Retrieved files(s).')
        end
        # Loop through albums and add files
        logger.info('Adding file(s) to album(s).')
        albums.each do |album|
            uri = URI.parse(@uri + "/Albums/#{album.id}/Files")
            res = post(uri, files, false)
            return false unless res.kind_of?(Net::HTTPSuccess)
        end
        true
    end
end
