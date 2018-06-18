module AddFilesToAlbum

	def __add_files_to_album(albums='',files='')

            if albums.empty? || albums.nil?
                logger.error("Albums (argument 1) cannot be empty.")
                return false
            end

            if files.empty? || files.nil?
                logger.error("Files (argument 2) cannot be empty.")
                return false
            end

            # Get album objects
            if albums.is_a?(Albums)
                albums = [albums]
            elsif albums.is_a?(String) || albums.is_a?(Integer)
                ids = albums.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
                op = RestOptions.new
                op.add_option('id',ids)
                albums = get_albums(op)
                op.clear
            elsif albums.is_a?(Array)
                if albums.first.is_a?(String) || albums.first.is_a?(Integer)
                    op = RestOptions.new
                    op.add_option('id',albums)
                    albums = get_albums(op)
                    op.clear
                    if albums.empty?
                        logger.error("Albums with id(s) => #{albums.join(',')} not found.")
                        return false
                    end
                end
            else
                logger.error("Expected Albums object(s), string id(s), array of id(s) for first argument. " +
                             "Instead Got => #{albums.to_s.inspect}.")
                return false
            end

            logger.info("Retrieved album(s).")

            # Get File objects
            if files.is_a?(Files)
                files = [files]
            elsif files.is_a?(String) || files.is_a?(Integer)
                ids = files.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
                op = RestOptions.new
                op.add_option('id',ids)
                files = get_files(op)
                op.clear
            elsif files.is_a?(Array)
                if files.first.is_a?(String) || files.first.is_a?(Integer)
                    op = RestOptions.new
                    op.add_option('id',files)
                    files = get_albums(op)
                    op.clear
                    if files.empty?
                        logger.error("Files with id(s) => #{files.join(',')} not found.")
                        return false
                    end
                end
            else
                logger.error("Expected Files object(s), string id(s), array of id(s) for second argument. " +
                             "Instead Got => #{files.to_s.inspect}.")
                return false
            end

            logger.info("Retrieved album(s).")

            # Loop through albums and add files
            logger.info("Adding files to album.")
            albums.each do |album|
                uri = URI.parse(@uri + "/Albums" + "/#{album.id}" + "/Files")
                res = post(uri,files,false)
                return false unless res.kind_of?(Net::HTTPSuccess)
            end
            return true
        end
end