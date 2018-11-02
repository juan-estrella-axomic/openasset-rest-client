module AssignHeroImages

    private

    def __assign_hero_images(options)

        # Helps when some params are specified but not others
        attribute  = options['attribute']  || 'rank'
        overwrite  = options['overwrite']  || true
        order      = options['order']      || 'asc'
        value      = options['value']
        batch_size = options['batch_size'] || 250

        desc_values = %w(descending des desc descend)
        # Verify we can sort using provided field
        unless Files.new.respond_to?(attribute)
            logger.error(%Q{Invalid image field "#{attribute}"})
            return
        end

        op = RestOptions.new
        op.add_option('limit',0)
        op.add_option('withHeroImage',1)
        op.add_option('displayFields','id,hero_image_id')

        if overwrite.eql?(false)
            op.add_option('hero_image_id',0) # Only grab projects w/o hero images
        end

        logger.info('Retrieving projects.')
        projects            = get_projects(op)
        project_ids         = projects.map { |p| p.id.to_s }
        project_lookup      = projects.each_with_object({}) { |proj,hash| hash[proj.id.to_s] = proj }
        project_file_lookup = projects.each_with_object({}) { |proj,hash| hash[proj.id.to_s] = [] }

        logger.info('Retrieving files.')

        project_id_batch_size = 50
        count,remainder       = project_ids.length.divmod(project_id_batch_size)
        count                += 1 if remainder > 0
        files                 = []

        project_ids.each_slice(project_id_batch_size).with_index(1) do |proj_ids,i|
            logger.info("Retrieving file batch #{i} of #{count}")
            op.clear
            op.add_option('limit',0)
            op.add_option('project_id',proj_ids)
            op.add_option('displayFields',"id,project_id,#{attribute}")
            file_batch = get_files(op)
            files << file_batch
        end

        files.flatten!
        file_lookup = {}

        files.each do |f|
            found = project_file_lookup[f.project_id.to_s]
            abort("project id #{f.project_id} not found!") unless found
            project_file_lookup[f.project_id.to_s] << f
        end

        projects_to_update = []

        project_file_lookup.each do |proj_id,file_array|
            # Sort files for current project
            next if file_array.empty?
            file_array      = file_array.sort_by { |f| f.send("#{attribute}") }
            file_array      = file_array.reverse if desc_values.include?(order)
            hero_image_file = file_array.first
            project = project_lookup[proj_id.to_s]
            next if value && !hero_image_file.send("#{attribute}").to_s.eql?(value.to_s)
            project.hero_image_id = hero_image_file.id
            projects_to_update << project
        end

        count,remainder = projects_to_update.length.divmod(batch_size)
        count          += 1 if remainder > 0

        projects_to_update.each_slice(batch_size).with_index(1) do |batch,i|
            logger.info("Updating project batch #{i} of #{count}")
            res = update_projects(batch)
            logger.info(res)
        end
        logger.info("Hero image assignment complete.")
    end

end