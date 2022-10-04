
# IISConfigDSC
This module contains DSC resources for configuring IIS settings.

## DSC Resources

### IISApplicationHost
Configure settings in the applicationhost.config file

### IISMachineConfig
Configure settings in the machine.config file

### RegistryForwardSlash
Alternative for the native Registry DSC Resource, which does not support the use of forward slashes in the key. RegistryForwardSlash uses .NET to work around this limitation. CIS IIS hardening recommends to implement some Cipher registry keys, of which some contain a forward slash in the key. 

## Examples
```Powershell 
# Examples from CIS IIS10 Hardening
# 1.3 (L1) Ensure 'directory browsing' is set to disabled (Scored)
IISApplicationHost maxAllowedContentLength {
    PSPath = 'IIS:\'
    Filter = 'system.webserver/directorybrowse'
    Name   = 'Enabled'
    Value  = $false
}

# 2.6 (L1) Ensure transport layer security for 'basic authentication' is configured (Scored)
IISApplicationHost SSLFlags {
    PSPath = 'MACHINE/WEBROOT/APPHOST'
    Filter = 'system.webServer/security/access'
    Name   = 'SSLFlags'
    Value  = 'Ssl'
}

# 3.1 (L1) Ensure 'deployment method retail' is set (Scored)
IISMachineConfig Retail {
    Section  = 'system.web/deployment'
    Property = 'Retail'
    Value    = $true
}

# 7.11 (L1) Ensure AES 256/256 Cipher Suite is Enabled (Scored)
RegistryForwardSlash AES {
    Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256'
    ValueName = Enabled
    ValueType = Dword
    ValueData = 1
}
```