# ApplicationHost
function Get-IISApplicationHost {
    Param(
        [Parameter(Mandatory)][string]$PSPath,

        [Parameter(Mandatory)][string]$Filter,

        [Parameter(Mandatory)][string]$Name
    )
    
    try {
        $get = Get-WebConfigurationProperty -PSPath $PSPath -Filter $Filter -Name $Name -ErrorAction Stop
    } catch {
        Write-Warning "Could not get Property $Name from $Filter"
    }

    # Ensure Value is fully expanded
    $Properties = ($get | Get-Member -ErrorAction SilentlyContinue).Name

    if ( $Properties -contains 'Value' ) {
        $get = $get.Value
    }

    # Workaround to convert boolean output to string because test value is string
    if ($get -eq $true) {
        $get = 'True'
    } elseif ($get -eq $false) {
        $get = 'False'
    }

    return @{
        PSPath = $PSPath
        Filter = $Filter
        Name = $Name
        Value = $get
    }
}

function Test-IISApplicationHost {
    Param(
        [Parameter(Mandatory)][string]$PSPath,

        [Parameter(Mandatory)][string]$Filter,

        [Parameter(Mandatory)][string]$Name,

        [Parameter()]$Value
    )

    $get = Get-IISApplicationHost -PSPath $PSPath -Filter $Filter -Name $Name

    if ($get.Value -eq $value) {
        $test = $true
        Write-Verbose -Message "Property $Name at $Filter is in desired state"
    }
    else {
        $test = $false
        Write-Verbose -Message "Property $Name with value $($get.Value) at $Filter does not have desired value $Value"
    }

    return $test
}

function Set-IISApplicationHost {
    Param(
        [Parameter(Mandatory)][string]$PSPath,

        [Parameter(Mandatory)][string]$Filter,

        [Parameter(Mandatory)][string]$Name,

        [Parameter()]$Value
    )

    # Workaround to convert string boolean to boolean type
    if ($Value -eq '$true') {
        $Value = $true
    } elseif ($Value -eq '$false') {
        $Value = $false
    }

    Write-Verbose -Message "Setting Property $Name at $Filter to value $Value"
    Set-WebConfigurationProperty -PSPath $PSPath -Filter $Filter -Name $Name -Value $Value
}

[DscResource()]
class IISApplicationHost {
    [DSCProperty(Mandatory)]
    [string]$PSPath

    [DSCProperty(Key)]
    [string]$Filter

    [DSCProperty(Key)]
    [string]$Name

    [DSCProperty()]
    [string]$Value

    [void] ImportModule () {
        Import-Module -Name IISAdministration -Verbose:$false
    }

    [IISApplicationHost] Get () {
        $get = Get-IISApplicationHost -PSPath $this.PSPath -Filter $this.Filter -Name $this.name
        return $get
    }

    [void] Set () {
        $set = Set-IISApplicationHost -PSPath $this.PSPath -Filter $this.Filter -Name $this.Name -Value $this.Value
    }

    [bool] Test () {
        $test = Test-IISApplicationHost -PSPath $this.PSPath -Filter $this.Filter -Name $this.Name -Value $this.Value
        return $test
    }
}

# MachineConfig
function Get-MachineConfig {
    Param(
        [Parameter(Mandatory)][String]$Section,

        [Parameter(Mandatory)][String]$Property
    )

    $MachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
    $get = $MachineConfig.GetSection($Section).$Property

    return @{
        Section  = $Section
        Property = $Property
        Value    = $get
    }
}

function Test-MachineConfig {
    Param(
        [Parameter(Mandatory)][String]$Section,

        [Parameter(Mandatory)][String]$Property,

        [Parameter(Mandatory)]$Value
    )

    $get = Get-MachineConfig -Section $this.Section -Property $this.Property

    if ($get.Value -eq $Value) {
        $test = $true
        Write-Verbose -Message "Property $Property at $Section is in desired state"
    } else {
        $test = $false
        Write-Verbose -Message "Property $Property with value $($get.Value) at $Section does not have desired value $Value"
    }

    return $test
}

function Set-MachineConfig {
    Param(
        [Parameter(Mandatory)][String]$Section,

        [Parameter(Mandatory)][String]$Property,

        [Parameter(Mandatory)]$Value
    )

    Write-Verbose -Message "Changing value Property $Property at $Section from $($get.Value) to $Value"

    $MachineConfig = [System.Configuration.ConfigurationManager]::OpenMachineConfiguration()
    $MachineConfig.GetSection($Section).$Property = $Value
    $MachineConfig.Save()
}

[DscResource()]
class IISMachineConfig {
    [DSCProperty(Key)]
    [string]$Section

    [DSCProperty(Key)]
    [string]$Property

    [DSCProperty()]
    [string]$Value

    [IISMachineConfig] Get () {
        $get = Get-MachineConfig -Section $this.Section -Property $this.Property
        return $get
    }

    [void] Set () {
        $set = Set-MachineConfig -Section $this.Section -Property $this.Property -Value $this.Value
    }

    [bool] Test () {
        $test = Test-MachineConfig -Section $this.Section -Property $this.Property -Value $this.Value
        return $test
    }
}

# RegistryForwardSlash
function Get-RegistryForwardSlash {
    Param(
        [Parameter(Mandatory)][string]$Key,

        [Parameter(Mandatory)][string]$ValueName
    )

    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME)
    
    if (Test-Path $Key) {
        $RegistryKey = $Registry.OpensubKey($($Key.Replace('HKLM:\','')),$true)

        $get = $RegistryKey.GetValue($ValueName)
    } else {
        $get = 'None'
    }
    
    return @{
        Key = $Key
        ValueName = $ValueName
        ValueData = $get
    }
}

function Test-RegistryForwardSlash {
    Param(
        [Parameter(Mandatory)][string]$Key,

        [Parameter(Mandatory)][string]$ValueName,

        [Parameter(Mandatory)][int]$ValueData
    )

    $get = Get-RegistryForwardSlash -Key $this.Key -ValueName $this.ValueName

    if ($get.ValueData -ne $ValueData) {
        Write-Verbose -Message "$(Join-Path -Path $Key -ChildPath $ValueName) with value $($get) does not have desired value $($ValueData)"
        $test = $false
    }
    else {
        $test = $true
        Write-Verbose -Message "$(Join-Path -Path $Key -ChildPath $ValueName) is in desired state"   
    }

    return $test
}

function Set-RegistryForwardSlash {
    Param(
        [Parameter(Mandatory)][string]$Key,

        [Parameter(Mandatory)][string]$ValueName,

        [Parameter(Mandatory)][string]$ValueType,

        [Parameter(Mandatory)][int]$ValueData
    )

    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME)

    if (-not (Test-Path $Key)) {
        $Registry.CreateSubKey($($Key.Replace('HKLM:\','')))
    }

    $RegistryKey = $Registry.OpensubKey($($Key.Replace('HKLM:\','')),$true)

    Write-Verbose -Message "Setting $(Join-Path -Path $Key -ChildPath $ValueName) to $($ValueData)"
    $RegistryKey.SetValue($ValueName,$ValueData,$ValueType)
}

[DscResource()]
class RegistryForwardSlash {
    [DSCProperty(Key)]
    [string]$Key

    [DSCProperty(Key)]
    [string]$ValueName

    [DSCProperty(Mandatory)]
    [string]$ValueType

    [DSCProperty(Mandatory)]
    [int]$ValueData

    [RegistryForwardSlash] Get () {
        $get = Get-RegistryForwardSlash -Key $this.Key -ValueName $this.ValueName
        return $get
    }

    [void] Set () {
        $set = Set-RegistryForwardSlash -Key $this.Key -ValueName $this.ValueName -ValueType $this.ValueType -ValueData $this.ValueData
    }

    [bool] Test () {
        $test = Test-RegistryForwardSlash -Key $this.Key -ValueName $this.ValueName -ValueData $this.ValueData
        return $test
    }
}