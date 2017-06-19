require_relative 'Modules.rb'


#########################
#     Helper Classes    #
#########################

#Add additional functionality from the Modules file
#and add it to builtin ruby Array class

class Array
    include CSVHelper
    include DownloadHelper
end



