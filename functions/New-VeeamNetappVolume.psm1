function New-VeeamNetappVolume {
    <#
    .DESCRIPTION
        Creates a new a NetApp Volume and adds it to Veeam Configuration as a NAS Backup Job.

    .NOTES
        File Name  : New-VeeamNetappVolume.psm1
        Author     : Markus Kraus
        Version    : 1.0
        State      : Dev

    .LINK
        https://mycloudrevolution.com/

    .EXAMPLE
    New-VeeamNetappVolume -VeeamCacheRepo 'Default Backup Repository' -VolType NFS -IP 10.0.2.16 `
    -ExportPolicyName veeam -VolName vol_nfs_001 -VolSize 1 -NetAppAggregate aggr1_data01 `
    -NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default


    .PARAMETER Type
    Type of the new Volume

    .PARAMETER IP
    IP for the NFS Export

    .PARAMETER VolName
    Name of the new Volume

    .PARAMETER VolSize
    Size of the new Volume in GB

    .PARAMETER NetAppAggregateName
     Name of the Aggregate where the Volume is created

    .PARAMETER NetAppVserverName
    Name of the SVM where the Volume is created

    .PARAMETER NetAppInterfaceName
    Name of the Interface that should be used for the mount

    .PARAMETER VeeamCacheRepo
    The Veeam Cache Repo Name

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="Type of the new Volume")]
        [ValidateNotNullorEmpty()]
        [ValidateSet("NFS")]
            [String]$VolType,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="IP for the NFS Export")]
        [ValidateNotNullorEmpty()]
            [ipaddress]$IP,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="Name of the Export Policy")]
        [ValidateNotNullorEmpty()]
            [String]$ExportPolicyName,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="Name of the new Volume")]
        [ValidateNotNullorEmpty()]
            [String]$VolName,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="Size of the new Volume in GB")]
        [ValidateNotNullorEmpty()]
            [int]$VolSize
    )

    DynamicParam {
        # Veeam Cache Repo
        $VeeamCacheRepoName = 'VeeamCacheRepo'
        $VeeamCacheRepoAttributeProperty = @{
            Mandatory = $true;
            ValueFromPipeline = $False;
            HelpMessage = 'The Veeam Cache Repo Name'
        }
        $VeeamCacheRepoAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $VeeamCacheRepoAttributeProperty

        $VeeamCacheRepoValidateSet = Get-VBRBackupRepository | Select-Object -ExpandProperty Name
        $VeeamCacheRepoValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($VeeamCacheRepoValidateSet)

        $VeeamCacheRepoAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $VeeamCacheRepoAttributeCollection.Add($VeeamCacheRepoAttribute)
        $VeeamCacheRepoAttributeCollection.Add($VeeamCacheRepoValidateSetAttribute)

        $VeeamCacheRepoRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($VeeamCacheRepoName, [string], $VeeamCacheRepoAttributeCollection)

        # NetApp vServer parameter
        $NetAppVserverName = 'NetAppVserver'
        $NetAppVserverAttributeProperty = @{
            Mandatory = $true;
            ValueFromPipeline = $False;
            HelpMessage = 'The NetApp Vserver Name'
        }
        $NetAppVserverAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $NetAppVserverAttributeProperty

        $NetAppVserverValidateSet = (Get-NcVserver).where({$_.VserverType -eq "data"}) | Select-Object -ExpandProperty Vserver
        $NetAppVserverValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($NetAppVserverValidateSet)

        $NetAppVserverAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $NetAppVserverAttributeCollection.Add($NetAppVserverAttribute)
        $NetAppVserverAttributeCollection.Add($NetAppVserverValidateSetAttribute)

        $NetAppVserverRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($NetAppVserverName, [string], $NetAppVserverAttributeCollection)

        # NetApp Aggregate parameter
        $NetAppAggregateName = 'NetAppAggregate'
        $NetAppAggregateAttributeProperty = @{
            Mandatory = $true;
            ValueFromPipeline = $False;
            HelpMessage = 'The NetApp Aggregate Name'
        }
        $NetAppAggregateAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $NetAppAggregateAttributeProperty

        $NetAppAggregateValidateSet = Get-NcAggr | Select-Object -ExpandProperty Name
        $NetAppAggregateValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($NetAppAggregateValidateSet)

        $NetAppAggregateAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $NetAppAggregateAttributeCollection.Add($NetAppAggregateAttribute)
        $NetAppAggregateAttributeCollection.Add($NetAppAggregateValidateSetAttribute)

        $NetAppAggregateRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($NetAppAggregateName, [string], $NetAppAggregateAttributeCollection)

        # NetApp Interface parameter
        $NetAppInterfaceName = 'NetAppInterface'
        $NetAppInterfaceAttributeProperty = @{
            Mandatory = $true;
            ValueFromPipeline = $False;
            HelpMessage = 'The NetApp Interface Name'
        }
        $NetAppInterfaceAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $NetAppInterfaceAttributeProperty

        $NetAppInterfaceValidateSet = (Get-NcNetInterface).where({$_.DataProtocols -match "nfs|cifs"}) | Select-Object -ExpandProperty InterfaceName
        $NetAppInterfaceValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($NetAppInterfaceValidateSet)

        $NetAppInterfaceAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $NetAppInterfaceAttributeCollection.Add($NetAppInterfaceAttribute)
        $NetAppInterfaceAttributeCollection.Add($NetAppInterfaceValidateSetAttribute)

        $NetAppInterfaceRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($NetAppInterfaceName, [string], $NetAppInterfaceAttributeCollection)

        # NetApp SnapShot Policy parameter
        $NetAppSnapshotPolicyName = 'NetAppSnapshotPolicy'
        $NetAppSnapshotPolicyAttributeProperty = @{
            Mandatory = $true;
            ValueFromPipeline = $False;
            HelpMessage = 'The NetApp Aggregate Name'
        }
        $NetAppSnapshotPolicyAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $NetAppSnapshotPolicyAttributeProperty

        $NetAppSnapshotPolicyValidateSet = (Get-NcSnapshotPolicy).where({$_.Enabled -eq "True"}) | Select-Object -ExpandProperty Policy
        $NetAppSnapshotPolicyValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($NetAppSnapshotPolicyValidateSet)

        $NetAppSnapshotPolicyAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $NetAppSnapshotPolicyAttributeCollection.Add($NetAppSnapshotPolicyAttribute)
        $NetAppSnapshotPolicyAttributeCollection.Add($NetAppSnapshotPolicyValidateSetAttribute)

        $NetAppSnapshotPolicyRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($NetAppSnapshotPolicyName, [string], $NetAppSnapshotPolicyAttributeCollection)

        # Create and return parameter dictionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParameterDictionary.Add($VeeamCacheRepoName, $VeeamCacheRepoRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppAggregateName, $NetAppAggregateRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppVserverName, $NetAppVserverRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppInterfaceName, $NetAppInterfaceRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppSnapshotPolicyName, $NetAppSnapshotPolicyRuntimeParameter)

        $RuntimeParameterDictionary
    }

    Begin {

        # Assign DynamicParams to actual variables
        $VeeamCacheRepoName = $PsBoundParameters[$VeeamCacheRepoName]
        $NetAppAggregateName = $PsBoundParameters[$NetAppAggregateName]
        $NetAppVserverName = $PsBoundParameters[$NetAppVserverName]
        $NetAppInterfaceName = $PsBoundParameters[$NetAppInterfaceName]
        $NetAppSnapshotPolicyName = $PsBoundParameters[$NetAppSnapshotPolicyName]

        # Get real objects from parameters
        try {
            $VeeamCacheRepo = Get-VBRBackupRepository -Name $VeeamCacheRepoName
        }catch{ Throw "Failed to get Veeam Cache Repo" }

        try {
            $NetAppAggr = Get-NcAggr -Name $NetAppAggregateName
        }catch{ Throw "Failed to get NetApp Aggr" }

        try {
            $NetAppVserver = Get-NcVserver -Name $NetAppVserverName
        }catch{ Throw "Failed to get NetApp vServer (SVM)" }

        try {
            $NetAppInterface = Get-NcNetInterface -Name $NetAppInterfaceName
        }catch{ Throw "Failed to get NetApp Interface)" }

        try {
            $NetAppSnapshotPolicy = Get-NcSnapshotPolicy -Name $NetAppSnapshotPolicyName
        }catch{ Throw "Failed to get NetApp Snapshot Policy)" }

        if ($DebugPreference -eq "Inquire") {
                "NetApp Aggregate:"
                $NetAppAggr | Format-Table -Autosize
                "NetApp Vserver (SVM):"
                $NetAppVserver | Format-Table -Autosize
                "NetApp Interface:"
                $NetAppInterface | Format-Table -Autosize
                "NetApp Snapshot Policy:"
                $NetAppSnapshotPolicy | Format-Table -Autosize

        }

        $VolSizeByte = $VolSize * 130023424

    }

    Process {

        #$ClientMatch = $IPs -join ","
        $ClientMatch = $IP

        if(!($NetAppExportPolicy = Get-NcExportPolicy -Name $ExportPolicyName -VserverContext $NetAppVserver )){
            "Create new NetApp Export Policy '$($ExportPolicyName)' on SVM '$($NetAppVserver.Name)' ..."
            $NetAppExportPolicy = New-NcExportPolicy -Name $ExportPolicyName -VserverContext $NetAppVserver
            $NetAppExportRule = New-NcExportRule -VserverContext $NetAppVserver  -Policy $NetAppExportPolicy.PolicyName -ClientMatch $ClientMatch `
            -Protocol NFS -Index 1 -SuperUserSecurityFlavor any -ReadOnlySecurityFlavor any -ReadWriteSecurityFlavor any
        }else{
            "NetApp Export Policy '$($ExportPolicyName)' on SVM '$($NetAppVserver.Name)' aleady exists, add IP"
            $NetAppExportRule = New-NcExportRule -VserverContext $NetAppVserver  -Policy $NetAppExportPolicy.PolicyName -ClientMatch $ClientMatch `
            -Protocol NFS -Index 1 -SuperUserSecurityFlavor any -ReadOnlySecurityFlavor any -ReadWriteSecurityFlavor any

            }

        "Create new NetApp Volume '$VolName' on Aggregate '$($NetAppAggr.AggregateName)' ..."
        $NetAppVolume = New-NcVol -VserverContext $NetAppVserver -Name $VolName -Aggregate $NetAppAggr.AggregateName -JunctionPath $("/" + $VolName) `
        -ExportPolicy $ExportPolicyName -Size $VolSizeByte -SnapshotReserve 20 -SnapshotPolicy $NetAppSnapshotPolicy.Policy

        "Set Advanced Options for NetApp Volume '$VolName' ..."
        $NetAppVolume | Set-NcVolOption -Key fractional_reserve -Value 0
        $NetAppVolume | Set-NcVolOption -Key guarantee -Value none

        "Add New Veeam NAS Server '$($NetAppInterface.Address):/$($VolName)'"
        $VBRNASNFSServer = Add-VBRNASNFSServer -Path "$($NetAppInterface.Address):/$($VolName)" -CacheRepository $VeeamCacheRepo

    }

}
