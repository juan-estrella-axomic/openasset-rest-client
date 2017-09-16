require_relative 'Modules'


#########################
#     Helper Classes    #
#########################

#Add additional functionality from the Modules file
#and add it to builtin ruby Array class

class Array
    include CSVHelper
    include DownloadHelper
end



