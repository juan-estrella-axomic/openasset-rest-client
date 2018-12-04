require_relative 'Authenticator'
require_relative 'FileFinder'
require_relative 'SQLParser'
require_relative 'MyLogger'

module FileRestorer

    def restore_deleted_files(query_string='')

		synopsis = <<-EOT
Usage Example:
	rest_client.restore_deleted_files('where (deleted_user_id = 17 or deleted_user_id = 9) and (deleted > 20180809000000 and filename like "%bummy joe%")')

EOT
		if query_string.empty?
            Logging.logger.error('Query cannot be an empty string')
            abort(synopsis)
		end

		if !query_string.is_a?(String)
            Logging.logger.error('Query must be a string')
            abort(synopsis)
		end

		unless Authenticator.is_axomic_user?
            Logging.logger.error('You must log in as Axomic to perform this operation')
            abort
		end

        expressions = SQLParser.parse_query(query_string)

		options = RestOptions.new
		options.add_options('limit',0)
        options.add_options('alive',0)
        options.add_options('displayFields','id')

        deleted_file_ids = get_files(options)

        batch_size = 250
        files_to_be_restored = []
        count,remainder = file_ids.length.divmod(batch_size)
        count += 1 if remainder > 0

        options.clear
        deleted_file_ids.each_slice(batch_size).with_index(1) do |ids,i|
            Logging.logger.info("Retrieving batch #{i} of #{count}")
            options.add_options('limit',0)
            options.add_options('id',ids)
            files = get_files(options)
            matches = FileFinder.find_files(expressions,files)
            files_to_be_restored.concat(matches)
        end

        files_to_be_restored.each do |file|
            file.alive = 1
        end

        count,remainder = files_to_be_restored.length.divmod(batch_size)
        count += 1 if remainder > 0
        files_to_be_restored.each_slice(batch_size).with_index(1) do |batch,i|
            Logging.logger.info("Restoring files: Updating batch #{i} of #{c}")
            update_files(batch)
        end
        Logging.logger.info("Total Files Restored => #{file_ids.length}")
    end

end