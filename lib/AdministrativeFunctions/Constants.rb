module Constants
    
    RESTRICTED_LIST_FIELD_TYPES   = %w[ suggestion fixedSuggestion option ]
    NORMAL_FIELD_TYPES            = %w[ singleLine multiLine ]
    ALLOWED_BOOLEAN_FIELD_OPTIONS = %w[ enable disable yes no set unset check uncheck tick untick on off true false 1 0 ]

    IMAGE_BUILT_IN_FIELD_CODES    = [ "_filecopyrightholder", "_filephotographer" ]
    IMAGE_BUILT_IN_FIELD_NAMES    = [ "copyright holder", "photographer" ]

    #PROJECT_BUILT_IN_FIELD_NAMES  = [ "code alias 1", "code alias 2", "name alias 1", "name alias 2" ]
        
end