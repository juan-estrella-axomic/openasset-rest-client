module AddUsersToGroups

    def  __add_users_to_groups(groups,users)

        if (groups.is_a?(Array) && groups.empty?) || users.empty? || groups.nil?
            logger.error("Groups (argument 1) cannot be empty.")
            return false
        end

        if (users.is_a?(Array) && users.empty?) || users.empty? || users.nil?
            logger.error("Files (argument 2) cannot be empty.")
            return false
        end

        # Get group objects
        if groups.is_a?(Groups)
            groups = [groups]
        elsif groups.is_a?(String) || groups.is_a?(Integer)
            ids = groups.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
            op = RestOptions.new
            op.add_option('id',ids)
            groups = get_groups(op)
            op.clear
        elsif groups.is_a?(Array)
            if groups.first.is_a?(String) || groups.first.is_a?(Integer)
                op = RestOptions.new
                op.add_option('id',groups)
                groups = get_groups(op)
                op.clear
                if groups.empty?
                    logger.error("Groups with id(s) => #{groups.join(',')} not found.")
                    return false
                end
            end
        else
            logger.error("Expected Groups object(s), string id(s), array of id(s) for first argument. " +
                         "Instead Got => #{groups.to_s.inspect}.")
            return false
        end

        logger.info("Retrieved group(s).")

        # Get User objects
        if users.is_a?(Users)
            users = [users]
        elsif users.is_a?(String) || users.is_a?(Integer)
            ids = users.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
            op = RestOptions.new
            op.add_option('id',ids)
            users = get_users(op,true)
            op.clear
        elsif users.is_a?(Array)
            if users.first.is_a?(String) || users.first.is_a?(Integer)
                op = RestOptions.new
                op.add_option('id',users)
                users = get_groups(op,true)
                op.clear
                if users.empty?
                    logger.error("Users with id(s) => #{users.join(',')} not found.")
                    return false
                end
            end
        else
            logger.error("Expected Users object(s), string id(s), array of id(s) for second argument. " +
                         "Instead Got => #{users.to_s.inspect}.")
            return false
        end

        # Loop through groups and add users

       # groups.each do |group|
       #    uri = URI.parse(@uri + "/Groups" + "/#{group.id}" + "/Users")
       #     res = post(uri,users,false)
       #     #return false unless res.kind_of?(Net::HTTPSuccess)
       # end

        # Ensure files objects include the nested groups
        if users.first.groups.empty?
            ids = users.map { |user| user.id }
            options = RestOptions.new.tap do |o|
                o.add_option('id',ids)
                o.add_option('limit','0')
                o.add_option('displayFields','id,groups')
            end
            users = get_users(options,true) # Get users with nested resources
        end

        logger.info("Retrieved user(s).")

        payload = []
        groups.each do |group|
            users.each do |user|
                # Skip ids 3 and 4 to protect Axomic and Superuser
                next if user.id == "3" || user.id == "4"
                nested_group_found = user.groups.find { |obj| obj.id == group.id }
                user.groups << NestedGroupItems.new(group.id) unless nested_group_found
                payload << user
            end
        end

        logger.info("Adding user(s) to group(s).")
        res = update_users(payload)

        res.kind_of?(Net::HTTPSuccess) ? true : false

    end

end