module AddUsersToGroups

    def  __add_users_to_groups(*args)

        # Put arguments in array first for simpler validation below
        arg1   = args[0].is_a?(Array) ? args[0] : [args[0]]
        arg2   = args[1].is_a?(Array) ? args[1] : [args[1]]

        if arg1.first.to_s.empty? || arg2.first.to_s.empty? # Check for nil and empty string at once
            logger.error("Empty argument detected in #{__callee__}.")
            return false
        end

        groups = nil
        users  = nil

        if arg1.first.is_a?(Groups) && arg2.first.is_a?(Users)
            groups = arg1
            users  = arg2
        elsif arg1.is_a?(Users) && arg2.is_a?(Groups)
            users  = arg1
            groups = arg2
        else
            logger.error("Expected one of the following (in any order) for #{__callee__}:" +
                         "\n\t1.) One Groups object and One Users object." +
                         "\n\t2.) An Array of Groups objects and an Array of Users objects." +
                         "\n\t3.) One Groups object and an array of Users objects." +
                         "\n\t4.) One Users object and an array of Groups objects." +
                         "Instead got => #{arg1.inspect} and #{arg2.inspect}")
            return
        end

        # Loop through groups and add users
        # Ensure users objects include the nested groups field
        refetch = false
        users.each do |user|
            if user.groups.empty? || user.groups.to_s.empty? # <= in case it is set to nil or an empty string
                refetch = true
                break
            end
        end

        if refetch
            logger.info("Detected missing nested groups field. Refetching user(s).")
            ids = users.map { |user| user.id }
            options = RestOptions.new.tap do |o|
                o.add_option('id',ids)
                o.add_option('limit','0')
                o.add_option('displayFields','id,groups')
            end
            users = get_users(options,true) # Get users with nested resources
        end

        groups.each do |group|
            users.each do |user|
                # Skip ids 3 and 4 to protect Axomic and Superuser
                next if user.id == "3" || user.id == "4"
                nested_group_found = user.groups.find { |obj| obj.id == group.id }
                user.groups << NestedGroupItems.new(group.id) unless nested_group_found
            end
        end

        logger.info("Adding user(s) to group(s).")

        # Perform updates in batches of 200
        batch_size = 200
        total, remainder = users.length.divmod(batch_size)
        total += 1 if remainder > 0
        success = true
        users.each_slice(batch_size).with_index(1) do |batch,index|
            logger.info("Updating user batch #{index} of #{total}.")
            res = update_users(batch)
            logger.info(res)
            success = false unless res.kind_of?(Net::HTTPSuccess)
        end

        success
    end

end