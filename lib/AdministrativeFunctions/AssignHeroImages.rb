module AssignHeroImages

    private
    def __assign_hero_images(str='rank',batch_size=250)

        # Verify we can sort using provided field
        unless Files.new.respond_to?(str)
            logger.error("Invalid image field #{str}")
            return
        end

        op = RestOptions.new
        op.add_option('limit',0)
        op.add_option('withHeroImage',1)
        op.add_option('displayFields','id,hero_image_id')

        logger.info('Retrieving projects.')
        projects = get_projects(op)
        project_ids = projects.map { |p| p.id.to_s }
        project_file_lookup = projects.each_with_object({}) { |proj,hash| hash[proj.id.to_s] = [] }

        op.clear
        op.add_option('limit',0)
        op.add_option('project_id',project_ids)
        op.add_option('displayFields',"id,project_id,#{str}")

        logger.info('Retrieving files.')
        files = get_files(op)
        file_lookup = {}
        files.each { |f| project_file_lookup[f.project_id.to_s] << f }

        # files.each do |f|
        #     # Verify file doesn't belong to a deleted project
        #     project_found = project_lookup[f.project_id.to_s]
        #     unless project_found
        #         msg = "File id #{f.id} is in a deleted project "
        #         msg += "with id #{f.project_id}. Skipping."
        #         logger.error(msg)
        #         next
        #     end

        #     file_lookup[f.project_id.to_s] << f
        # end

        projects_to_update = []
        project_file_lookup.each do |proj_id,file_array|
            # Sort files for current project
            if file_array.empty?
                p proj_id
                p file_array
                p file_lookup
                abort("Oops array empty")
            end
            hero_image = file_array.sort_by { |f| f.send("#{str}") }.first
            project = project_lookup[proj_id.to_s]
            project.hero_image_id = hero_image.id
            projects_to_update << project
        end

        count,remainder = projects_to_update.length.divmod(batch_size)
        count += 1 if remainder > 0

        projects_to_update.each_slice(batch_size).with_index(1) do |batch,i|
            logger.info("Updating batch #{i} of #{count}")
            res = update_projects(batch)
            logger.info(res.message)
        end

        logger.info("Hero image assignment complete.")
    end

end