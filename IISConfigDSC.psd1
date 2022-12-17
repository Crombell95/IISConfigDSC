@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'IISConfigDSC.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.0'
    
    # ID used to uniquely identify this module
    GUID = '75e78a13-1bdf-420c-9d86-68525b9ef62e'
    
    # Author of this module
    Author = 'Crombell95'
    
    # Company or vendor of this module
    CompanyName = ''
    
    # Copyright statement for this module
    Copyright = ''
    
    # Description of the functionality provided by this module
    Description = 'DSC resources to modify IIS settings in applicationhost.config and machine.config'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('IISAdministration')
    
    # Functions to export from this module
    FunctionsToExport = @()
    
    # DSC resources to export from this module
    DscResourcesToExport = @(
        'IISApplicationHost'
        'IISMachineConfig'
        'RegistryForwardSlash'
    )
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                'PSModule'
                'IIS'
                'DSC'
                'DesiredStateConfiguration'
                'DSCResource'
            )
    
            # A URL to the license for this module.
            # LicenseUri = ''
    
            # A URL to the main website for this project.
            # ProjectUri = ''
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
        } # End of PSData hashtable
    
    } 
}