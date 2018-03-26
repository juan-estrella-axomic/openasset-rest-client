module AddFilesToAlbum

	def __add_files_to_album(albums=nil,files=nil)
        
            return if albums.to_s.eql?('') && files.to_s.eql?('')
            # Get album objects
            if albums.is_a?(String) || albums.is_a?(Integer)
                
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
                    return false if albums.empty?
                end
                unless albums.first.is_a?(Albums) || albums.first.is_a?(String) || albums.first.is_a?(Integer)
                    logger.error("Expected Albums object(s), string id(s), array of id(s) for first argument. Instead Got => #{albums.to_s.inspect}.")
                    return false
                end
            end

            if albums.empty?
                logger.error("Album insertion error: Album(s) not found in OpenAsset.")
                return false
            end
            logger.info("Retrieved album(s).")


            # Get File objects
            if files.is_a?(String) || files.is_a?(Integer)
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
                    return false if files.empty?
                end
                unless files.first.is_a?(Files) || files.first.is_a?(String) || files.first.is_a?(Integer)
                    logger.error("Expected Files object(s), string id(s), array of id(s) for second argument. Instead Got => #{files.to_s.inspect}.")
                    return false
                end
            end
    
            if files.empty?
                logger.error("Album insertion error: File(s) not found in OpenAsset.")
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