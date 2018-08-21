require 'cgi'
require 'net/http'
require 'ruby-progressbar'

require_relative 'Validator'
require_relative 'MyLogger'
require_relative 'SmartUpdater'

class Downloader

    def self.download(uri,location)

        resource                  = uri.to_s.split('/').last               # => Files

        file_path_components      = location.split('/')                    # => ['path','to','tweedle%20dee%20%26%20tweedle%20dum%20%281%29.jpg']
        folders                   = file_path_components[0..-2]            # => Capture everything but the filename ['path', 'to']
        folder_path               = folders.join('/')                      # => Folder where file will be saved -> path/to

        possibly_encoded_filename = file_path_components.last              # => tweedle%20dee%20%26%20tweedle%20dum%20%281%29.jpg
        decoded_filename          = GCI.unescape(possibly_encoded_filename)# => tweedle dee & tweedle dum (1).jpg
        decoded_file_path         = folder_path + '/' + decoded_filename   # /path/to/tweedle dee & tweedle dum (1).jpg

        Logging.logger.info("Downloading file => #{decoded_filename}")

        begin
            retries ||= 0

            Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
                # Perform head request to get the content length to feed the progress bar      
                res = http.request_head(uri)
                file_size = res['content-length'].to_i
                response = Validator.process_http_response(res,true,resource,'GET')

                return response unless response.kind_of? Net::HTTPSuccess

                pbar = ProgressBar.create(:format => '%p%% [%b>%i] %r KB/sec  ETA %e',
                                          :rate_scale => lambda { |rate| rate / 1024 },
                                          :starting_at => 0, 
                                          :total => file_size)

                File.open(decoded_file_path, 'wb') do |file|
                    http.request_get(uri.request_uri) do |resp|
                        resp.read_body do |chunk|
                            file.write(chunk)
                            pbar.progress += chunk.size
                        end
                    end
                end
            end

        rescue SocketError => e

            Logging.logger.warn("Socket Error: #{e}.")
            Logging.logger.warn( "Path => #{uri}")
            SmartUpdater.wait_and_try_again
            retry if (retries += 1) < 20
            abort(e)

        rescue StandardError => e

            Logging.logger.warn("Exception: #{e}.")
            Logging.logger.warn("Path => #{uri}")
            SmartUpdater.wait_and_try_again
            retry if (retries += 1) < 5
            abort(e)

        end
    end

end

