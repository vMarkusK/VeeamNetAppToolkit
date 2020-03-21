---
external help file: New-VeeamNetappVolume-help.xml
Module Name: VeeamNetAppToolkit
online version: https://mycloudrevolution.com/
schema: 2.0.0
---

# New-VeeamNetappVolume

## SYNOPSIS

## SYNTAX

### NFS
```
New-VeeamNetappVolume [-CreateBackupJob] [-NFS] -IP <IPAddress> -ExportPolicyName <String> -VolName <String>
 -VolSize <Int32> [<CommonParameters>]
```

### SMB
```
New-VeeamNetappVolume [-CreateBackupJob] [-SMB] -VolName <String> -VolSize <Int32> [<CommonParameters>]
```

## DESCRIPTION
Creates a new a NetApp Volume and adds it to Veeam Configuration as a NAS Backup Job.

## EXAMPLES

### EXAMPLE 1
```
New-VeeamNetappVolume -NFS -IP 10.0.2.16 -ExportPolicyName veeam -VolName vol_nfs_01 -VolSize 1 -VeeamCacheRepo 'Default Backup Repository' -NetAppAggregate aggr1_data01 -NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default
```

### EXAMPLE 2
```
New-VeeamNetappVolume -NFS -IP 10.0.2.16 -ExportPolicyName veeam -VolName vol_nfs_01 -VolSize 1 -CreateBackupJob -VeeamBackupRepo 'Default Backup Repository' -VeeamCacheRepo 'Default Backup Repository' -NetAppAggregate aggr1_data01 -NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default
```

## PARAMETERS

### -CreateBackupJob
Create a Backup Job fot the New NAS Server

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NFS
NFS Volume

```yaml
Type: SwitchParameter
Parameter Sets: NFS
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SMB
SMB Volume

```yaml
Type: SwitchParameter
Parameter Sets: SMB
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IP
IP for the NFS Export

```yaml
Type: IPAddress
Parameter Sets: NFS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPolicyName
Name of the Export Policy

```yaml
Type: String
Parameter Sets: NFS
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VolName
Name of the new Volume

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VolSize
Size of the new Volume in GB

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
File Name  : New-VeeamNetappVolume.psm1
Author     : Markus Kraus
Version    : 0.2
State      : Dev

## RELATED LINKS

[https://mycloudrevolution.com/](https://mycloudrevolution.com/)

