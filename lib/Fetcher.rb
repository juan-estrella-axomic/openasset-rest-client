require_relative 'MyLogger'
class Fetcher
    # fetches nouns
    include Logging

    def initialize
    end

    def get_objects(uri,batch_size=250)
        objects = []
        op = RestOptions.new do |o|
            o.add_options('limit',0)
            o.add_options('displayFields','id')
        end
        ids = get(uri,op)
        op.clear
        c,r = ids.length.divmod(batch_size)
        c += 1 if r > 0
        ids.each_slice(batch_size).with_index(1) do |subset,i|
            logger.info("Retrieving batch #{i} of #{c}")
            op.add_options('id',subset)
            batch = get(uri,op,true)
            objects.concat(batch)
        end
        objects
    end
end