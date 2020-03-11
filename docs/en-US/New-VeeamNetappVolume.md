---
external help file: New-VeeamNetappVolume-help.xml
Module Name: VeeamNetAppToolkit
online version: https://mycloudrevolution.com/
schema: 2.0.0
---

# New-VeeamNetappVolume

## SYNOPSIS

## SYNTAX

```
New-VeeamNetappVolume [-VolType] <String> [-IP] <IPAddress> [-ExportPolicyName] <String> [-VolName] <String>
 [-VolSize] <Int32> [<CommonParameters>]
```

## DESCRIPTION
Creates a new a NetApp Volume and adds it to Veeam Configuration as a NAS Backup Job.

## EXAMPLES

### EXAMPLE 1
```
New-VeeamNetappVolume -VeeamCacheRepo 'Default Backup Repository' -VolType NFS -IP 10.0.2.16 `
```

-ExportPolicyName veeam -VolName vol_nfs_001 -VolSize 1 -NetAppAggregate aggr1_data01 \`
-NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default

## PARAMETERS

### -VolType
Type of the new Volume

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IP
IP for the NFS Export

```yaml
Type: IPAddress
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExportPolicyName
Name of the Export Policy

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
Position: 4
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
Position: 5
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
Version    : 0.1
State      : Dev

## RELATED LINKS

[https://mycloudrevolution.com/](https://mycloudrevolution.com/)

