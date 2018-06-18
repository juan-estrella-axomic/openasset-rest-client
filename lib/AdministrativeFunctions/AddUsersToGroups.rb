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

        logger.info("Retrieved album(s).")

        # Get User objects
        if users.is_a?(Users)
            users = [users]
        elsif users.is_a?(String) || users.is_a?(Integer)
            ids = users.to_s.split(/,/).reject { |v| v.strip.empty? || v.to_i.eql?(0) }
            op = RestOptions.new
            op.add_option('id',ids)
            users = get_users(op)
            op.clear
        elsif users.is_a?(Array)
            if users.first.is_a?(String) || users.first.is_a?(Integer)
                op = RestOptions.new
                op.add_option('id',users)
                users = get_groups(op)
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

        logger.info("Retrieved album(s).")

        # Loop through groups and add users
        logger.info("Adding users to album.")
        groups.each do |group|
            uri = URI.parse(@uri + "/Groups" + "/#{group.id}" + "/Users")
            res = post(uri,users,false)
            return false unless res.kind_of?(Net::HTTPSuccess)
        end
        return true
    end


end