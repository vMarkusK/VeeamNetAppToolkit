function New-VeeamNetappVolume {
    <#
    .DESCRIPTION
    Creates a new a NetApp Volume and adds it to Veeam Configuration as a NAS Backup Job.

    .NOTES
    File Name  : New-VeeamNetappVolume.psm1
    Author     : Markus Kraus
    Version    : 0.2
    State      : Dev

    .LINK
    https://mycloudrevolution.com/

    .EXAMPLE
    New-VeeamNetappVolume -NFS -IP 10.0.2.16 -ExportPolicyName veeam -VolName vol_nfs_01 -VolSize 1 -VeeamCacheRepo 'Default Backup Repository' -NetAppAggregate aggr1_data01 -NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default

    .EXAMPLE
    New-VeeamNetappVolume -NFS -IP 10.0.2.16 -ExportPolicyName veeam -VolName vol_nfs_01 -VolSize 1 -CreateBackupJob -VeeamBackupRepo 'Default Backup Repository' -VeeamCacheRepo 'Default Backup Repository' -NetAppAggregate aggr1_data01 -NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default

    .PARAMETER CreateBackupJob
    Create a Backup Job fot the New NAS Server

    .PARAMETER NFS
    NFS Volume

    .PARAMETER SMB
    SMB Volume

    .PARAMETER IP
    IP for the NFS Export

    .PARAMETER VolName
    Name of the new Volume

    .PARAMETER VolSize
    Size of the new Volume in GB

    .PARAMETER VeeamBackupRepo
    The Veeam Backup Repo Name

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
        [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Create Backup Job")]
        [ValidateNotNullorEmpty()]
            [Switch]$CreateBackupJob,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="NFS Volume", ParameterSetName="NFS")]
        [ValidateNotNullorEmpty()]
            [Switch]$NFS,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="SMB Volume", ParameterSetName="SMB")]
        [ValidateNotNullorEmpty()]
            [Switch]$SMB,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="IP for the NFS Export", ParameterSetName="NFS")]
        [ValidateNotNullorEmpty()]
            [ipaddress]$IP,
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="Name of the Export Policy", ParameterSetName="NFS")]
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

        # Veeam Backup Repo
        $VeeamBackupRepoName = 'VeeamBackupRepo'
        $VeeamBackupRepoAttributeProperty = @{
            Mandatory = $false;
            ValueFromPipeline = $False;
            HelpMessage = 'The Veeam Backup Repo Name'
        }
        $VeeamBackupRepoAttribute = New-Object System.Management.Automation.ParameterAttribute -Property $VeeamBackupRepoAttributeProperty

        $VeeamBackupRepoValidateSet = Get-VBRBackupRepository | Select-Object -ExpandProperty Name
        $VeeamBackupRepoValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($VeeamBackupRepoValidateSet)

        $VeeamBackupRepoAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $VeeamBackupRepoAttributeCollection.Add($VeeamBackupRepoAttribute)
        $VeeamBackupRepoAttributeCollection.Add($VeeamBackupRepoValidateSetAttribute)

        $VeeamBackupRepoRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($VeeamBackupRepoName, [string], $VeeamBackupRepoAttributeCollection)

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
        if ($CreateBackupJob){
                $RuntimeParameterDictionary.Add($VeeamBackupRepoName, $VeeamBackupRepoRuntimeParameter)
        }
        $RuntimeParameterDictionary.Add($NetAppAggregateName, $NetAppAggregateRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppVserverName, $NetAppVserverRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppInterfaceName, $NetAppInterfaceRuntimeParameter)
        $RuntimeParameterDictionary.Add($NetAppSnapshotPolicyName, $NetAppSnapshotPolicyRuntimeParameter)

        $RuntimeParameterDictionary
    }

    Begin {

        # Assign DynamicParams to actual variables
        $VeeamCacheRepoName = $PsBoundParameters[$VeeamCacheRepoName]
        if ($VeeamBackupRepoName){
            $VeeamBackupRepoName = $PsBoundParameters[$VeeamBackupRepoName]
        }
        $NetAppAggregateName = $PsBoundParameters[$NetAppAggregateName]
        $NetAppVserverName = $PsBoundParameters[$NetAppVserverName]
        $NetAppInterfaceName = $PsBoundParameters[$NetAppInterfaceName]
        $NetAppSnapshotPolicyName = $PsBoundParameters[$NetAppSnapshotPolicyName]

        # Get real objects from parameters
        try {
            $VeeamCacheRepo = Get-VBRBackupRepository -Name $VeeamCacheRepoName
        }catch{ Throw "Failed to get Veeam Cache Repo" }

        if ($VeeamBackupRepoName){
            try {
                $VeeamBackupRepo = Get-VBRBackupRepository -Name $VeeamBackupRepoName
            }catch{ Throw "Failed to get Veeam Backup Repo" }
        }

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

        if ($NFS) {

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
            $VBRNAServer = Add-VBRNASNFSServer -Path "$($NetAppInterface.Address):/$($VolName)" -CacheRepository $VeeamCacheRepo

        }
        elseif ($SMB) {
            "Not Implemented. Sorry..."
        }
        else { Throw "No Volume Type choosen!"}

        if ($CreateBackupJob) {
            if ($NFS) {
                $Object = New-VBRNASBackupJobObject -Server $VBRNAServer -Path "$($NetAppInterface.Address):/$($VolName)"
            }
            elseif ($SMB) {
                "Not Implemented. Sorry..."
            }

            "Add Veeam Backup Job for NetApp Volume '$VolName' ..."
            $VBRNAServerBackupJob = Add-VBRNASBackupJob -BackupObject $Object -ShortTermBackupRepository $VeeamBackupRepo
        }

    }

}
