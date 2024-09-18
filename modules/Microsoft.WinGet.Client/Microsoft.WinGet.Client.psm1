# Module created by Microsoft.PowerShell.Crescendo
class PowerShellCustomFunctionAttribute : System.Attribute { 
  [bool]$RequiresElevation
  [string]$Source
  PowerShellCustomFunctionAttribute() { $this.RequiresElevation = $false; $this.Source = "Microsoft.PowerShell.Crescendo" }
  PowerShellCustomFunctionAttribute([bool]$rElevation) {
      $this.RequiresElevation = $rElevation
      $this.Source = "Microsoft.PowerShell.Crescendo"
  }
}

<#
.SYNOPSIS
Enables the WinGet setting specified by the `Name` parameter.

.DESCRIPTION
Enables the WinGet setting specified by the `Name` parameter.
Supported settings:
  - LocalManifestFiles
  - BypassCertificatePinningForMicrosoftStore
  - InstallerHashOverride
  - LocalArchiveMalwareScanOverride

.PARAMETER Name
Specifies the name of the setting to be enabled.

.INPUTS
None.

.OUTPUTS
None

.EXAMPLE
PS> Enable-WinGetSetting -name LocalManifestFiles 
#>
function Enable-WinGetSetting
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding(SupportsShouldProcess)]

param(
[Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
[string]$Name
  )

BEGIN {
  $__PARAMETERMAP = @{
       Name = @{
             OriginalName = ''
             OriginalPosition = '0'
             Position = '0'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
  }

  $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
}

PROCESS {
  $__boundParameters = $PSBoundParameters
  $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
  $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
  $__commandArgs = @()
  $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
  if ($__boundParameters["Debug"]){wait-debugger}
  $__commandArgs += 'settings'
  $__commandArgs += '--enable'
  foreach ($paramName in $__boundParameters.Keys|
          Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
          Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
      $value = $__boundParameters[$paramName]
      $param = $__PARAMETERMAP[$paramName]
      if ($param) {
          if ($value -is [switch]) {
               if ($value.IsPresent) {
                   if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
               }
               elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
          }
          elseif ( $param.NoGap ) {
              $pFmt = "{0}{1}"
              if($value -match "\s") { $pFmt = "{0}""{1}""" }
              $__commandArgs += $pFmt -f $param.OriginalName, $value
          }
          else {
              if($param.OriginalName) { $__commandArgs += $param.OriginalName }
              $__commandArgs += $value | Foreach-Object {$_}
          }
      }
  }
  $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
  if ($__boundParameters["Debug"]){wait-debugger}
  if ( $__boundParameters["Verbose"]) {
       Write-Verbose -Verbose -Message winget.exe
       $__commandArgs | Write-Verbose -Verbose
  }
  $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
  if (! $__handlerInfo ) {
      $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
  }
  $__handler = $__handlerInfo.Handler
  if ( $PSCmdlet.ShouldProcess("winget.exe $__commandArgs")) {
  # check for the application and throw if it cannot be found
      if ( -not (Get-Command -ErrorAction Ignore "winget.exe")) {
        throw "Cannot find executable 'winget.exe'"
      }
      if ( $__handlerInfo.StreamOutput ) {
          & "winget.exe" $__commandArgs | & $__handler
      }
      else {
          $result = & "winget.exe" $__commandArgs
          & $__handler $result
      }
  }
} # end PROCESS
}

<#
.SYNOPSIS
Disables the WinGet setting specified by the `Name` parameter.

.DESCRIPTION
Disables the WinGet setting specified by the `Name` parameter.
Supported settings:
  - LocalManifestFiles
  - BypassCertificatePinningForMicrosoftStore
  - InstallerHashOverride
  - LocalArchiveMalwareScanOverride

.PARAMETER Name
Specifies the name of the setting to be disabled.

.INPUTS
None.

.OUTPUTS
None

.EXAMPLE
PS> Disable-WinGetSetting -name LocalManifestFiles 
#>
function Disable-WinGetSetting
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding(SupportsShouldProcess)]

param(
[Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
[string]$Name
  )

BEGIN {
  $__PARAMETERMAP = @{
       Name = @{
             OriginalName = ''
             OriginalPosition = '0'
             Position = '0'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
  }

  $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
}

PROCESS {
  $__boundParameters = $PSBoundParameters
  $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
  $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
  $__commandArgs = @()
  $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
  if ($__boundParameters["Debug"]){wait-debugger}
  $__commandArgs += 'settings'
  $__commandArgs += '--disable'
  foreach ($paramName in $__boundParameters.Keys|
          Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
          Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
      $value = $__boundParameters[$paramName]
      $param = $__PARAMETERMAP[$paramName]
      if ($param) {
          if ($value -is [switch]) {
               if ($value.IsPresent) {
                   if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
               }
               elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
          }
          elseif ( $param.NoGap ) {
              $pFmt = "{0}{1}"
              if($value -match "\s") { $pFmt = "{0}""{1}""" }
              $__commandArgs += $pFmt -f $param.OriginalName, $value
          }
          else {
              if($param.OriginalName) { $__commandArgs += $param.OriginalName }
              $__commandArgs += $value | Foreach-Object {$_}
          }
      }
  }
  $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
  if ($__boundParameters["Debug"]){wait-debugger}
  if ( $__boundParameters["Verbose"]) {
       Write-Verbose -Verbose -Message winget.exe
       $__commandArgs | Write-Verbose -Verbose
  }
  $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
  if (! $__handlerInfo ) {
      $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
  }
  $__handler = $__handlerInfo.Handler
  if ( $PSCmdlet.ShouldProcess("winget.exe $__commandArgs")) {
  # check for the application and throw if it cannot be found
      if ( -not (Get-Command -ErrorAction Ignore "winget.exe")) {
        throw "Cannot find executable 'winget.exe'"
      }
      if ( $__handlerInfo.StreamOutput ) {
          & "winget.exe" $__commandArgs | & $__handler
      }
      else {
          $result = & "winget.exe" $__commandArgs
          & $__handler $result
      }
  }
} # end PROCESS
}

<#
.SYNOPSIS
Get winget settings.

.DESCRIPTION
Get the administrator settings values as well as the location of the user settings as json string

.PARAMETER Name
None

.INPUTS
None.

.OUTPUTS
Prints the export settings json.

.EXAMPLE
PS> Get-WinGetSettings
#>
function Get-WinGetSettings
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding(SupportsShouldProcess)]

param(    )

BEGIN {
  $__PARAMETERMAP = @{}
  $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
}

PROCESS {
  $__boundParameters = $PSBoundParameters
  $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
  $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
  $__commandArgs = @()
  $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
  if ($__boundParameters["Debug"]){wait-debugger}
  $__commandArgs += 'settings'
  $__commandArgs += 'export'
  foreach ($paramName in $__boundParameters.Keys|
          Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
          Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
      $value = $__boundParameters[$paramName]
      $param = $__PARAMETERMAP[$paramName]
      if ($param) {
          if ($value -is [switch]) {
               if ($value.IsPresent) {
                   if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
               }
               elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
          }
          elseif ( $param.NoGap ) {
              $pFmt = "{0}{1}"
              if($value -match "\s") { $pFmt = "{0}""{1}""" }
              $__commandArgs += $pFmt -f $param.OriginalName, $value
          }
          else {
              if($param.OriginalName) { $__commandArgs += $param.OriginalName }
              $__commandArgs += $value | Foreach-Object {$_}
          }
      }
  }
  $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
  if ($__boundParameters["Debug"]){wait-debugger}
  if ( $__boundParameters["Verbose"]) {
       Write-Verbose -Verbose -Message winget.exe
       $__commandArgs | Write-Verbose -Verbose
  }
  $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
  if (! $__handlerInfo ) {
      $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
  }
  $__handler = $__handlerInfo.Handler
  if ( $PSCmdlet.ShouldProcess("winget.exe $__commandArgs")) {
  # check for the application and throw if it cannot be found
      if ( -not (Get-Command -ErrorAction Ignore "winget.exe")) {
        throw "Cannot find executable 'winget.exe'"
      }
      if ( $__handlerInfo.StreamOutput ) {
          & "winget.exe" $__commandArgs | & $__handler
      }
      else {
          $result = & "winget.exe" $__commandArgs
          & $__handler $result
      }
  }
} # end PROCESS
}

<#
.SYNOPSIS
Add a new source.

.DESCRIPTION
Add a new source. A source provides the data for you to discover and install packages.
Only add a new source if you trust it as a secure location.

.PARAMETER Name
Name of the source.

.PARAMETER Argument
Argument to be given to the source.

.PARAMETER Type
Type of the source.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
PS> Add-WinGetSource -Name Contoso -Argument https://www.contoso.com/cache

#>
function Add-WinGetSource
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding(SupportsShouldProcess)]

param(
[Parameter(Position=0,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
[string]$Name,
[Parameter(Position=1,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
[string]$Argument,
[Parameter(Position=2,ValueFromPipelineByPropertyName=$true)]
[string]$Type
  )

BEGIN {
  $__PARAMETERMAP = @{
       Name = @{
             OriginalName = '--name'
             OriginalPosition = '0'
             Position = '0'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
       Argument = @{
             OriginalName = '--arg'
             OriginalPosition = '0'
             Position = '1'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
       Type = @{
             OriginalName = '--type'
             OriginalPosition = '0'
             Position = '2'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
  }

  $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
}

PROCESS {
  $__boundParameters = $PSBoundParameters
  $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
  $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
  $__commandArgs = @()
  $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
  if ($__boundParameters["Debug"]){wait-debugger}
  $__commandArgs += 'source'
  $__commandArgs += 'add'
  foreach ($paramName in $__boundParameters.Keys|
          Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
          Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
      $value = $__boundParameters[$paramName]
      $param = $__PARAMETERMAP[$paramName]
      if ($param) {
          if ($value -is [switch]) {
               if ($value.IsPresent) {
                   if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
               }
               elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
          }
          elseif ( $param.NoGap ) {
              $pFmt = "{0}{1}"
              if($value -match "\s") { $pFmt = "{0}""{1}""" }
              $__commandArgs += $pFmt -f $param.OriginalName, $value
          }
          else {
              if($param.OriginalName) { $__commandArgs += $param.OriginalName }
              $__commandArgs += $value | Foreach-Object {$_}
          }
      }
  }
  $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
  if ($__boundParameters["Debug"]){wait-debugger}
  if ( $__boundParameters["Verbose"]) {
       Write-Verbose -Verbose -Message winget.exe
       $__commandArgs | Write-Verbose -Verbose
  }
  $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
  if (! $__handlerInfo ) {
      $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
  }
  $__handler = $__handlerInfo.Handler
  if ( $PSCmdlet.ShouldProcess("winget.exe $__commandArgs")) {
  # check for the application and throw if it cannot be found
      if ( -not (Get-Command -ErrorAction Ignore "winget.exe")) {
        throw "Cannot find executable 'winget.exe'"
      }
      if ( $__handlerInfo.StreamOutput ) {
          & "winget.exe" $__commandArgs | & $__handler
      }
      else {
          $result = & "winget.exe" $__commandArgs
          & $__handler $result
      }
  }
} # end PROCESS
}

<#
.SYNOPSIS
Remove a specific source.

.DESCRIPTION
Remove a specific source. The source must already exist to be removed.

.PARAMETER Name
Name of the source.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
PS> Remove-WinGetSource -Name Contoso

#>
function Remove-WinGetSource
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding(SupportsShouldProcess)]

param(
[Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
[string]$Name
  )

BEGIN {
  $__PARAMETERMAP = @{
       Name = @{
             OriginalName = '--name'
             OriginalPosition = '0'
             Position = '0'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
  }

  $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
}

PROCESS {
  $__boundParameters = $PSBoundParameters
  $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
  $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
  $__commandArgs = @()
  $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
  if ($__boundParameters["Debug"]){wait-debugger}
  $__commandArgs += 'source'
  $__commandArgs += 'remove'
  foreach ($paramName in $__boundParameters.Keys|
          Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
          Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
      $value = $__boundParameters[$paramName]
      $param = $__PARAMETERMAP[$paramName]
      if ($param) {
          if ($value -is [switch]) {
               if ($value.IsPresent) {
                   if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
               }
               elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
          }
          elseif ( $param.NoGap ) {
              $pFmt = "{0}{1}"
              if($value -match "\s") { $pFmt = "{0}""{1}""" }
              $__commandArgs += $pFmt -f $param.OriginalName, $value
          }
          else {
              if($param.OriginalName) { $__commandArgs += $param.OriginalName }
              $__commandArgs += $value | Foreach-Object {$_}
          }
      }
  }
  $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
  if ($__boundParameters["Debug"]){wait-debugger}
  if ( $__boundParameters["Verbose"]) {
       Write-Verbose -Verbose -Message winget.exe
       $__commandArgs | Write-Verbose -Verbose
  }
  $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
  if (! $__handlerInfo ) {
      $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
  }
  $__handler = $__handlerInfo.Handler
  if ( $PSCmdlet.ShouldProcess("winget.exe $__commandArgs")) {
  # check for the application and throw if it cannot be found
      if ( -not (Get-Command -ErrorAction Ignore "winget.exe")) {
        throw "Cannot find executable 'winget.exe'"
      }
      if ( $__handlerInfo.StreamOutput ) {
          & "winget.exe" $__commandArgs | & $__handler
      }
      else {
          $result = & "winget.exe" $__commandArgs
          & $__handler $result
      }
  }
} # end PROCESS
}

<#
.SYNOPSIS
Drops existing sources. Without any argument, this command will drop all sources and add the defaults.

.DESCRIPTION
Drops existing sources, potentially leaving any local data behind. Without any argument, it will drop all sources and add the defaults.
If a named source is provided, only that source will be dropped.

.PARAMETER Name
Name of the source.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
PS> Reset-WinGetSource

.EXAMPLE
PS> Reset-WinGetSource -Name Contoso

#>
function Reset-WinGetSource
{
[PowerShellCustomFunctionAttribute(RequiresElevation=$False)]
[CmdletBinding(SupportsShouldProcess)]

param(
[Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
[string]$Name
  )

BEGIN {
  $__PARAMETERMAP = @{
       Name = @{
             OriginalName = '--name'
             OriginalPosition = '0'
             Position = '0'
             ParameterType = 'string'
             ApplyToExecutable = $False
             NoGap = $False
             }
  }

  $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }
}

PROCESS {
  $__boundParameters = $PSBoundParameters
  $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name
  $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})
  $__commandArgs = @()
  $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})
  if ($__boundParameters["Debug"]){wait-debugger}
  $__commandArgs += 'source'
  $__commandArgs += 'reset'
  $__commandArgs += '--force'
  foreach ($paramName in $__boundParameters.Keys|
          Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|
          Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
      $value = $__boundParameters[$paramName]
      $param = $__PARAMETERMAP[$paramName]
      if ($param) {
          if ($value -is [switch]) {
               if ($value.IsPresent) {
                   if ($param.OriginalName) { $__commandArgs += $param.OriginalName }
               }
               elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }
          }
          elseif ( $param.NoGap ) {
              $pFmt = "{0}{1}"
              if($value -match "\s") { $pFmt = "{0}""{1}""" }
              $__commandArgs += $pFmt -f $param.OriginalName, $value
          }
          else {
              if($param.OriginalName) { $__commandArgs += $param.OriginalName }
              $__commandArgs += $value | Foreach-Object {$_}
          }
      }
  }
  $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}
  if ($__boundParameters["Debug"]){wait-debugger}
  if ( $__boundParameters["Verbose"]) {
       Write-Verbose -Verbose -Message winget.exe
       $__commandArgs | Write-Verbose -Verbose
  }
  $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]
  if (! $__handlerInfo ) {
      $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present
  }
  $__handler = $__handlerInfo.Handler
  if ( $PSCmdlet.ShouldProcess("winget.exe $__commandArgs")) {
  # check for the application and throw if it cannot be found
      if ( -not (Get-Command -ErrorAction Ignore "winget.exe")) {
        throw "Cannot find executable 'winget.exe'"
      }
      if ( $__handlerInfo.StreamOutput ) {
          & "winget.exe" $__commandArgs | & $__handler
      }
      else {
          $result = & "winget.exe" $__commandArgs
          & $__handler $result
      }
  }
} # end PROCESS
}


# SIG # Begin signature block
# MIInvwYJKoZIhvcNAQcCoIInsDCCJ6wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCT2ffBa2miLYWO
# JGFTEASXNvxKC5iasFzIHbQiSIwGK6CCDXYwggX0MIID3KADAgECAhMzAAADTrU8
# esGEb+srAAAAAANOMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjMwMzE2MTg0MzI5WhcNMjQwMzE0MTg0MzI5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDdCKiNI6IBFWuvJUmf6WdOJqZmIwYs5G7AJD5UbcL6tsC+EBPDbr36pFGo1bsU
# p53nRyFYnncoMg8FK0d8jLlw0lgexDDr7gicf2zOBFWqfv/nSLwzJFNP5W03DF/1
# 1oZ12rSFqGlm+O46cRjTDFBpMRCZZGddZlRBjivby0eI1VgTD1TvAdfBYQe82fhm
# WQkYR/lWmAK+vW/1+bO7jHaxXTNCxLIBW07F8PBjUcwFxxyfbe2mHB4h1L4U0Ofa
# +HX/aREQ7SqYZz59sXM2ySOfvYyIjnqSO80NGBaz5DvzIG88J0+BNhOu2jl6Dfcq
# jYQs1H/PMSQIK6E7lXDXSpXzAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUnMc7Zn/ukKBsBiWkwdNfsN5pdwAw
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMDUxNjAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAD21v9pHoLdBSNlFAjmk
# mx4XxOZAPsVxxXbDyQv1+kGDe9XpgBnT1lXnx7JDpFMKBwAyIwdInmvhK9pGBa31
# TyeL3p7R2s0L8SABPPRJHAEk4NHpBXxHjm4TKjezAbSqqbgsy10Y7KApy+9UrKa2
# kGmsuASsk95PVm5vem7OmTs42vm0BJUU+JPQLg8Y/sdj3TtSfLYYZAaJwTAIgi7d
# hzn5hatLo7Dhz+4T+MrFd+6LUa2U3zr97QwzDthx+RP9/RZnur4inzSQsG5DCVIM
# pA1l2NWEA3KAca0tI2l6hQNYsaKL1kefdfHCrPxEry8onJjyGGv9YKoLv6AOO7Oh
# JEmbQlz/xksYG2N/JSOJ+QqYpGTEuYFYVWain7He6jgb41JbpOGKDdE/b+V2q/gX
# UgFe2gdwTpCDsvh8SMRoq1/BNXcr7iTAU38Vgr83iVtPYmFhZOVM0ULp/kKTVoir
# IpP2KCxT4OekOctt8grYnhJ16QMjmMv5o53hjNFXOxigkQWYzUO+6w50g0FAeFa8
# 5ugCCB6lXEk21FFB1FdIHpjSQf+LP/W2OV/HfhC3uTPgKbRtXo83TZYEudooyZ/A
# Vu08sibZ3MkGOJORLERNwKm2G7oqdOv4Qj8Z0JrGgMzj46NFKAxkLSpE5oHQYP1H
# tPx1lPfD7iNSbJsP6LiUHXH1MIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGZ8wghmbAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAANOtTx6wYRv6ysAAAAAA04wDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEICHhTe1PQrHG7rvFvug24KeZ
# 4NRpRCF8pvCuAm4okCS6MEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAJcYMml2aDbq88m7tdf2Ye04z/BcUkBJM2qPwajEpiJmAz7vXM02cpa/l
# ywRwga1VsF8gD5/eUxMLyd2j86KFK1iuALbVqSSzzWOrnaUEK8Wak7q5wTDv34UV
# uM2IZLINCCEi6wx5myP7v0mMZmoMIquSoLG6HDGjVqRRceyx2lJctjrg84GZ4QQl
# WXoJEwgKAG7lqjAp04UghpCKRIkl/P4MTHoNkRUV5y3S36t1atbYZuXo8OiZ0e5S
# bVAABDNhHjhOnxdiINu5mm54LhvcnT1VY0P/75QZLOrlXezijcj9XPB+ccuF99tb
# XCsq67QjPTTyMTPhr6my91TiaU9jkqGCFykwghclBgorBgEEAYI3AwMBMYIXFTCC
# FxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFZBgsq
# hkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCD1bqyLiSPNYHUKceC6qCZnejev6Ae2VBMgk5pGA+nrigIGZD/Sas35
# GBMyMDIzMDUxNjE4NDE1My44MzNaMASAAgH0oIHYpIHVMIHSMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJl
# bGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNO
# OjhENDEtNEJGNy1CM0I3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAGz/iXOKRsbihwAAQAAAbMwDQYJ
# KoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjIw
# OTIwMjAyMjAzWhcNMjMxMjE0MjAyMjAzWjCB0jELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3Bl
# cmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo4RDQxLTRC
# RjctQjNCNzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALR8D7rmGICuLLBggrK9je3h
# JSpc9CTwbra/4Kb2eu5DZR6oCgFtCbigMuMcY31QlHr/3kuWhHJ05n4+t377PHon
# dDDbz/dU+q/NfXSKr1pwU2OLylY0sw531VZ1sWAdyD2EQCEzTdLD4KJbC6wmACon
# iJBAqvhDyXxJ0Nuvlk74rdVEvribsDZxzClWEa4v62ENj/HyiCUX3MZGnY/AhDya
# zfpchDWoP6cJgNCSXmHV9XsJgXJ4l+AYAgaqAvN8N+EpN+0TErCgFOfwZV21cg7v
# genOV48gmG/EMf0LvRAeirxPUu+jNB3JSFbW1WU8Z5xsLEoNle35icdET+G3wDNm
# cSXlQYs4t94IWR541+PsUTkq0kmdP4/1O4GD54ZsJ5eUnLaawXOxxT1fgbWb9VRg
# 1Z4aspWpuL5gFwHa8UNMRxsKffor6qrXVVQ1OdJOS1JlevhpZlssSCVDodMc30I3
# fWezny6tNOofpfaPrtwJ0ukXcLD1yT+89u4uQB/rqUK6J7HpkNu0fR5M5xGtOch9
# nyncO9alorxDfiEdb6zeqtCfcbo46u+/rfsslcGSuJFzlwENnU+vQ+JJ6jJRUrB+
# mr51zWUMiWTLDVmhLd66//Da/YBjA0Bi0hcYuO/WctfWk/3x87ALbtqHAbk6i1cJ
# 8a2coieuj+9BASSjuXkBAgMBAAGjggFJMIIBRTAdBgNVHQ4EFgQU0BpdwlFnUgwY
# izhIIf9eBdyfw40wHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXwYD
# VR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9j
# cmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3JsMGwG
# CCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIw
# MjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQADggIBAFqGuzfOsAm4wAJf
# ERmJgWW0tNLLPk6VYj53+hBmUICsqGgj9oXNNatgCq+jHt03EiTzVhxteKWOLoTM
# x39cCcUJgDOQIH+GjuyjYVVdOCa9Fx6lI690/OBZFlz2DDuLpUBuo//v3e4Kns41
# 2mO3A6mDQkndxeJSsdBSbkKqccB7TC/muFOhzg39mfijGICc1kZziJE/6HdKCF8p
# 9+vs1yGUR5uzkIo+68q/n5kNt33hdaQ234VEh0wPSE+dCgpKRqfxgYsBT/5tXa3e
# 8TXyJlVoG9jwXBrKnSQb4+k19jHVB3wVUflnuANJRI9azWwqYFKDbZWkfQ8tpNoF
# fKKFRHbWomcodP1bVn7kKWUCTA8YG2RlTBtvrs3CqY3mADTJUig4ckN/MG6AIr8Q
# +ACmKBEm4OFpOcZMX0cxasopdgxM9aSdBusaJfZ3Itl3vC5C3RE97uURsVB2pvC+
# CnjFtt/PkY71l9UTHzUCO++M4hSGSzkfu+yBhXMGeBZqLXl9cffgYPcnRFjQT97G
# b/bg4ssLIFuNJNNAJub+IvxhomRrtWuB4SN935oMfvG5cEeZ7eyYpBZ4DbkvN44Z
# vER0EHRakL2xb1rrsj7c8I+auEqYztUpDnuq6BxpBIUAlF3UDJ0SMG5xqW/9hLMW
# naJCvIerEWTFm64jthAi0BDMwnCwMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJ
# mQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNh
# dGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1
# WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjK
# NVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhg
# fWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJp
# rx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/d
# vI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka9
# 7aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKR
# Hh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9itu
# qBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyO
# ArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItb
# oKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6
# bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6t
# AgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQW
# BBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacb
# UzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYz
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnku
# aHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIA
# QwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2
# VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwu
# bWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEw
# LTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYt
# MjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/q
# XBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6
# U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVt
# I1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis
# 9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTp
# kbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0
# sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138e
# W0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJ
# sWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7
# Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0
# dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQ
# tB1VM1izoXBm8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB0jELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
# bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjo4
# RDQxLTRCRjctQjNCNzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUAcYtE6JbdHhKlwkJeKoCV1JIkDmGggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AOgN6AAwIhgPMjAyMzA1MTYxOTMxMTJaGA8yMDIzMDUxNzE5MzExMlowdDA6Bgor
# BgEEAYRZCgQBMSwwKjAKAgUA6A3oAAIBADAHAgEAAgIQETAHAgEAAgIRJzAKAgUA
# 6A85gAIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAID
# B6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAG3AoQNyzjZl5J9+iOeI
# 9k3dvt+/aMUWKE+zYhleo/BUhmXJ7EdLPz/dKNPPYWOfx23rbg6a9AV1msUnXqMP
# T2PuzV2JxMwYfjzhVCctBpogPAQog8dro10zTPpd/f1nWK494vz18fuSRC2YbMFd
# DSAkzpuMrXe4v5UjPmnZEGIMMYIEDTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBIDIwMTACEzMAAAGz/iXOKRsbihwAAQAAAbMwDQYJYIZIAWUDBAIB
# BQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQx
# IgQgrcQJYOn9Mqvq3X8fDP8xZAnvIvnGWFnhJdiBJXy3I+cwgfoGCyqGSIb3DQEJ
# EAIvMYHqMIHnMIHkMIG9BCCGoTPVKhDSB7ZG0zJQZUM2jk/ll1zJGh6KOhn76k+/
# QjCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABs/4l
# zikbG4ocAAEAAAGzMCIEIGPa6R8EbWdQIXV33cTi8q9MB1sfx49fFwfe1Ko9EjOc
# MA0GCSqGSIb3DQEBCwUABIICAKBpSYRvR9GuD38v5m7fGzX8RQWiXi0AO5vEu/Tq
# 81kvwvcMb/bfV7m95t26b5Y8/Q4jRaz2hWTHFMhCHUndzX/W/oUEGkE/tG1UP9Nm
# MdJTiiENnTWjRx9/3hA8rs0dyquCmTsWJcfkc7VExInEIjPobeQl8JEZ0ITQYOg0
# Rc8wdFK3FxhaHFl8tjFMzyn77dliWuaLMq5nf9jshpdsu2LvvpdaXY40lxT2dhq/
# 1dFhlVsa1Q09ViqNK6eRD8cN1S82EIC9JQAhqlzWejxvjYbDhimiDLrBhy4yxd6r
# IEZGciocmg7v+WzXzlSWrT2WOVlWplkdq6+LaoA6us3pbdCBJxRsX4UCiEKpYT12
# kUQksbXLoWKC1Doyxg44ANgBAJ1GPPFEK+5tWRRm/49PI4ThLsNCAxkkQxCG4DIC
# ktPCdb+NFtVlhwHoHenY125WWgcADQb/wqrABBgIUrm6w4NL3iNYpxkWxV0OJeqg
# fyT3q0OzZ6c+8GSAR+0bU2v+Oe4csFTo86x42OjRNOty7dlFB68IBEekaM8W4lap
# TzvhSEllfCBeaPhycbt51g3BaHoFKc/MgLlZ8qXduMqkRu5paYXaxzpDQsSN8oUg
# BljgK2DE8+cA/+iTGPrjvGvzAkij1ShinWc79pJ7D73E7uRSsEzR7j3hmjSIXVpE
# gZc9
# SIG # End signature block
