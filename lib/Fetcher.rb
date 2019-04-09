require_relative 'MyLogger'
require_relative 'SmartUpdater'
require_relative './CRUDMethods/Get'
module Fetcher
    # fetches nouns
    private
    def get_objects(uri)
        objects    = []
        batch_size = 500
        options = RestOptions.new.tap do |o|
            o.add_options('limit',0)
            o.add_options('displayFields','id')
        end

        ids = get(uri,options,false).map { |obj| obj.id } # get ids for all object in table
        iterations,remainder = ids.length.divmod(batch_size)
        iterations          += 1 if remainder > 0

        ids.each_slice(batch_size).with_index(1) do |subset,i|
            logger.info("Retrieving batch #{i} of #{iterations}")
            options.clear

            # start_value = subset.first.to_s
            # end_value   = subset.last.to_s
            # id_range = start_value + '-' + end_value => less data in query but runs slower

            id_range = subset.join(',') # More data sent in query but runs faster => faster wins
            options.add_raw_options("id=#{id_range}")
            options.add_raw_options('limit=0')

            batch = get(uri,options,true) # true flag returns objects with ALL fields and sizes

            objects.concat(batch)
        end
        # API appears to be caching results. Need to look into this
        objects = objects.uniq { |o| o.id }
    end
end