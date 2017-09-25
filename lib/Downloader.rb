require 'net/http'
require 'ruby-progressbar'

require_relative 'Validator'
require_relative 'MyLogger'

class Downloader

    def self.download(uri,location)

        resource = uri.to_s.split('/').last
        filename = location.split('/').last

        Logging::logger.info( "Downloading file => #{filename}")

        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            # Perform head request to get the content length to feed the progress bar      
            res = http.request_head(uri)
            file_size = res['content-length'].to_i
            response = Validator::process_http_response(res,true,resource,'GET')
          
            return response unless response.kind_of? Net::HTTPSuccess

            pbar = ProgressBar.create(:format => '%p%% [%b>%i] %r KB/sec  ETA %e',
                                      :rate_scale => lambda { |rate| rate / 1024 },
                                      :starting_at => 0, 
                                      :total => file_size)

            File.open(location, "wb") do |file|
                
                http.request_get(uri.request_uri) do |resp|
                    
                    resp.read_body do |chunk|
                      
                        file.write(chunk)
                        pbar.progress += chunk.size
                   
                    end
                
                end
            
            end
       
        end
    
    end

end

