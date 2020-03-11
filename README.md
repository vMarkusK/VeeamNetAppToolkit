# vSphereNetAppToolkit PowerShell Module

[![Build status](https://ci.appveyor.com/api/projects/status/tnbdo5mf3c1iqn8l?svg=true)](https://ci.appveyor.com/project/mycloudrevolution/veeamnetapptoolkit)


## About

### Project Owner

Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)

my cloud-(r)evolution [mycloudrevolution.com](http://mycloudrevolution.com/)

### Project WebSite

[mycloudrevolution.com](http://mycloudrevolution.com/)

### Project Repository

[GitHub - VeeamNetAppToolkit](https://github.com/mycloudrevolution/vSphereNetAppToolkit)

### Project Documentation

[Read the Docs - VeeamNetAppToolkit](https://veeamnetapptoolkit.readthedocs.io)

### Project Description

This Module helps to automate some basic steps that interact between Veeam and NetApp ONTAP.

## Requirements

### NetApp

* NetApp DataONTAP PowerShell Module

```PowerShell
Import-Module DataONTAP
Connect-NcController 10.0.2.11
```

### Veeam

* Veeam PowerShell SnapIn

```PowerShell
Add-PSSnapin VeeamPSSnapin
Connect-VBRServer -Server localhost
```

## Functions

### New-VeeamNetappVolume

[![Watch the video](https://img.youtube.com/vi/n-ylGAn14jA/maxresdefault.jpg)](https://www.youtube.com/watch?v=n-ylGAn14jA)


```PowerShell
New-VeeamNetappVolume -VeeamCacheRepo 'Default Backup Repository' -VolType NFS -IP 10.0.2.16 `
-ExportPolicyName veeam -VolName vol_nfs_001 -VolSize 1 -NetAppAggregate aggr1_data01 `
-NetAppVserver svm_veeam_nfs -NetAppInterface svm_veeam_nfs_nfs_lif1 -NetAppSnapshotPolicy default
```