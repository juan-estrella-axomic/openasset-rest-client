require_relative 'MyLogger'
require_relative 'SmartUpdater'
require_relative './CRUDMethods/Get'
module Fetcher
    # fetches nouns
    private
    def get_objects(uri,batch_size=250)
        objects = []
        options = RestOptions.new.tap do |o|
            o.add_options('limit',0)
            o.add_options('displayFields','id')
        end
        ids = get(uri,options,false).map { |obj| obj.id }
        c,r = ids.length.divmod(batch_size)
        c += 1 if r > 0
        ids.each_slice(batch_size).with_index(1) do |subset,i|
            logger.info("Retrieving batch #{i} of #{c}")
            options.clear
            options.add_options('limit',0)
            options.add_options('id',subset)
            batch = get(uri,options,true)
            objects.concat(batch)
        end
        objects
    end
end