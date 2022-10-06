# Author: Roberto Rodriguez @Cyb3rWard0g
# License: GPLv3
configuration PrepareAD-MSExchange
{ 
   param 
   ( 
        [Parameter(Mandatory)]
        [String]$DomainFQDN,

        [Parameter(Mandatory)]
        [String]$DomainController,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$AdminCreds,

        [Parameter(Mandatory)]
        [String]$MXSISODirectory,

        [Parameter(Mandatory)]
        [ValidateSet('MXS2016-x64-CU23-KB5011155','MXS2016-x64-CU22-KB5005333','MXS2016-x64-CU21-KB500361','MXS2016-x64-CU20-KB4602569','MXS2016-x64-CU19-KB4588884','MXS2016-x64-CU18-KB4571788','MXS2016-x64-CU17-KB4556414','MXS2016-x64-CU16-KB4537678','MXS2016-x64-CU15-KB4522150','MXS2016-x64-CU14-KB4514140','MXS2016-x64-CU13-KB4488406','MXS2016-x64-CU12-KB4471392')]
        [string]$MXSRelease
    ) 
    
    Import-DscResource -ModuleName ComputerManagementDsc, xPSDesiredStateConfiguration, xExchange, StorageDsc

    [String] $DomainNetbiosName = (Get-NetBIOSName -DomainFQDN $DomainFQDN)
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)

    # Set MS Exchange ISO File
    # Reference: https://docs.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates?view=exchserver-2019&WT.mc_id=M365-MVP-5003086
    $MXSISOFile = Switch ($MXSRelease) {
        'MXS2016-x64-CU23-KB5011155' { @{ISO = 'ExchangeServer2016-x64-CU23.ISO'; CumulativeUpdate = 23} }
        'MXS2016-x64-CU22-KB5005333' { @{ISO = 'ExchangeServer2016-x64-CU22.ISO'; CumulativeUpdate = 22} }
        'MXS2016-x64-CU21-KB5003611' { @{ISO = 'ExchangeServer2016-x64-CU21.ISO'; CumulativeUpdate = 21} }
        'MXS2016-x64-CU20-KB4602569' { @{ISO = 'ExchangeServer2016-x64-CU20.ISO'; CumulativeUpdate = 20} }
        'MXS2016-x64-CU19-KB4588884' { @{ISO = 'ExchangeServer2016-x64-CU19.ISO'; CumulativeUpdate = 19} }
        'MXS2016-x64-CU18-KB4571788' { @{ISO = 'ExchangeServer2016-x64-cu18.iso'; CumulativeUpdate = 18} }
        'MXS2016-x64-CU17-KB4556414' { @{ISO = 'ExchangeServer2016-x64-cu17.iso'; CumulativeUpdate = 17} }
        'MXS2016-x64-CU16-KB4537678' { @{ISO = 'ExchangeServer2016-x64-CU16.ISO'; CumulativeUpdate = 16} }
        'MXS2016-x64-CU15-KB4522150' { @{ISO = 'ExchangeServer2016-x64-CU15.ISO'; CumulativeUpdate = 15} }
        'MXS2016-x64-CU14-KB4514140' { @{ISO = 'ExchangeServer2016-x64-cu14.iso'; CumulativeUpdate = 14} }
        'MXS2016-x64-CU13-KB4488406' { @{ISO = 'ExchangeServer2016-x64-cu13.iso'; CumulativeUpdate = 13} }
        'MXS2016-x64-CU12-KB4471392' { @{ISO = 'ExchangeServer2016-x64-cu12.iso'; CumulativeUpdate = 12} }
    }

    #https://docs.microsoft.com/en-us/Exchange/plan-and-deploy/prepare-ad-and-domains?view=exchserver-2016#exchange-2016-active-directory-versions
    $MXDirVersions = Switch ($MXSRelease) {
        'MXS2016-x64-CU23-KB5011155' { @{SchemaVersion = 15334; OrganizationVersion = 16223; DomainVersion = 13243} }
        'MXS2016-x64-CU22-KB5005333' { @{SchemaVersion = 15334; OrganizationVersion = 16222; DomainVersion = 13242} }
        'MXS2016-x64-CU21-KB5003611' { @{SchemaVersion = 15334; OrganizationVersion = 16221; DomainVersion = 13241} }
        'MXS2016-x64-CU20-KB4602569' { @{SchemaVersion = 15333; OrganizationVersion = 16220; DomainVersion = 13240} }
        'MXS2016-x64-CU19-KB4588884' { @{SchemaVersion = 15333; OrganizationVersion = 16219; DomainVersion = 13239} }
        'MXS2016-x64-CU18-KB4571788' { @{SchemaVersion = 15332; OrganizationVersion = 16218; DomainVersion = 13238} }
        'MXS2016-x64-CU17-KB4556414' { @{SchemaVersion = 15332; OrganizationVersion = 16217; DomainVersion = 13237} }
        'MXS2016-x64-CU16-KB4537678' { @{SchemaVersion = 15332; OrganizationVersion = 16217; DomainVersion = 13237} }
        'MXS2016-x64-CU15-KB4522150' { @{SchemaVersion = 15332; OrganizationVersion = 16217; DomainVersion = 13237} }
        'MXS2016-x64-CU14-KB4514140' { @{SchemaVersion = 15332; OrganizationVersion = 16217; DomainVersion = 13237} }
        'MXS2016-x64-CU13-KB4488406' { @{SchemaVersion = 15332; OrganizationVersion = 16217; DomainVersion = 13237} }
        'MXS2016-x64-CU12-KB4471392' { @{SchemaVersion = 15332; OrganizationVersion = 16215; DomainVersion = 13236} }
    }

    $MXSISOCU = $MXSISOFile.CumulativeUpdate
    $MXSISOFilePath = Join-Path $MXSISODirectory $MXSISOFile.ISO

    Node localhost
    {
        LocalConfigurationManager 
        {
            ActionAfterReboot   = 'ContinueConfiguration'
            ConfigurationMode   = 'ApplyOnly'
            RebootNodeIfNeeded  = $true
        }

        # ***** Mount Image *****
        MountImage MountMXSISO
        {
            Ensure = 'Present'
            ImagePath = $MXSISOFilePath
            DriveLetter = 'F'
        }

        WaitForVolume WaitForISO
        {
            DriveLetter      = 'F'
            RetryIntervalSec = 5
            RetryCount       = 10
            DependsOn = "[MountImage]MountMXSISO"
        }
        
        # #####################
        # Prepare Exchange AD #
        # #####################

        <#
        Prepare Schema
        --------------
        xExchInstall PrepSchema
		{
			Path = 'F:\Setup.exe'
            Arguments = "/PrepareSchema /DomainController:$DomainController.$DomainFQDN /IAcceptExchangeServerLicenseTerms"
            Credential = $DomainCreds
            DependsOn  = '[WaitForVolume]WaitForISO'
        }
        #>
        xScript PrepSchema
        {
            SetScript =
            {
                
                if ($($using:MXSISOCU) -ge 22) {
                    <#
                    https://support.microsoft.com/en-us/topic/setup-fails-for-unattended-installation-of-exchange-server-2019-cu11-or-2016-cu22-or-later-234d7d9a-a94e-4386-9384-46761edf9268
                    Exchange Server 2019 CU11 and Exchange Server 2016 CU22 introduce two new setup switches for the EULA, and remove an existing parameter (IAcceptExchangeServerLicenseTerms).
                    This change was made to enable administrators to set the state of diagnostic data collection that is done in Exchange Server 2019 CU11 and Exchange Server 2016 CU22 and later CUs.
                    To accept the EULA and set the state of diagnostic data collection, use either of following parameters:
                    - /IAcceptExchangeServerLicenseTerms_DiagnosticDataON (This parameter enables sending data to Microsoft.)
                    - /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF (This parameter disables sending data to Microsoft.)
                    #>
                    F:\Setup.exe /PrepareSchema /DomainController:$using:DomainController.$using:DomainFQDN /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF
                } else {
                    F:\Setup.exe /PrepareSchema /DomainController:$using:DomainController.$using:DomainFQDN /IAcceptExchangeServerLicenseTerms
                }
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                return $false
            }
            PsDscRunAsCredential = $DomainCreds
            DependsOn  = '[WaitForVolume]WaitForISO'
        }

        <#
        Prepare AD
        ----------
        xExchInstall PrepAD
		{
			Path = 'F:\Setup.exe'
            Arguments = "/PrepareAD /OrganizationName:$DomainNetbiosName /DomainController:$DomainController.$DomainFQDN /IAcceptExchangeServerLicenseTerms"
            Credential = $DomainCreds
            DependsOn  = '[xExchInstall]PrepSchema'
        }
        #>
        xScript PrepAD
        {
            SetScript =
            {
                if ($($using:MXSISOCU) -ge 22) {
                    <#
                    https://support.microsoft.com/en-us/topic/setup-fails-for-unattended-installation-of-exchange-server-2019-cu11-or-2016-cu22-or-later-234d7d9a-a94e-4386-9384-46761edf9268
                    Exchange Server 2019 CU11 and Exchange Server 2016 CU22 introduce two new setup switches for the EULA, and remove an existing parameter (IAcceptExchangeServerLicenseTerms).
                    This change was made to enable administrators to set the state of diagnostic data collection that is done in Exchange Server 2019 CU11 and Exchange Server 2016 CU22 and later CUs.
                    To accept the EULA and set the state of diagnostic data collection, use either of following parameters:
                    - /IAcceptExchangeServerLicenseTerms_DiagnosticDataON (This parameter enables sending data to Microsoft.)
                    - /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF (This parameter disables sending data to Microsoft.)
                    #>
                    F:\Setup.exe /PrepareAD /OrganizationName:$using:DomainNetbiosName /DomainController:$using:DomainController.$using:DomainFQDN /IAcceptExchangeServerLicenseTerms_DiagnosticDataOFF
                } else {
                    F:\Setup.exe /PrepareAD /OrganizationName:$using:DomainNetbiosName /DomainController:$using:DomainController.$using:DomainFQDN /IAcceptExchangeServerLicenseTerms
                }
            }
            GetScript =  
            {
                # This block must return a hashtable. The hashtable must only contain one key Result and the value must be of type String.
                return @{ "Result" = "false" }
            }
            TestScript = 
            {
                # If it returns $false, the SetScript block will run. If it returns $true, the SetScript block will not run.
                return $false
            }
            PsDscRunAsCredential = $DomainCreds
            DependsOn  = '[xScript]PrepSchema'
        }

        # https://docs.microsoft.com/en-us/Exchange/plan-and-deploy/prepare-ad-and-domains?view=exchserver-2016#step-2-prepare-active-directory
        xExchWaitForADPrep WaitPrepAD
        {
            Identity            = "not used"
            Credential          = $DomainCreds
            SchemaVersion       = $MXDirVersions.SchemaVersion
            OrganizationVersion = $MXDirVersions.OrganizationVersion
            DomainVersion       = $MXDirVersions.DomainVersion
            ExchangeDomains     = @("$DomainFQDN")
            RetryIntervalSec    = 60
            RetryCount          = 35
            DependsOn           = '[xScript]PrepAD'
        }

        # See if a reboot is required after Exchange PrepAD
        PendingReboot RebootAfterMXPrepAD
        { 
            Name = "RebootAfterMXInstall"
            DependsOn = '[xExchWaitForADPrep]WaitPrepAD'
        }     
    }
}

function Get-NetBIOSName {
    [OutputType([string])]
    param(
        [string]$DomainFQDN
    )

    if ($DomainFQDN.Contains('.')) {
        $length = $DomainFQDN.IndexOf('.')
        if ( $length -ge 16) {
            $length = 15
        }
        return $DomainFQDN.Substring(0, $length)
    }
    else {
        if ($DomainFQDN.Length -gt 15) {
            return $DomainFQDN.Substring(0, 15)
        }
        else {
            return $DomainFQDN
        }
    }
}