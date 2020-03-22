# Veeam NetApp Toolkit - PowerShell Module

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![Build status](https://ci.appveyor.com/api/projects/status/tnbdo5mf3c1iqn8l?svg=true)](https://ci.appveyor.com/project/mycloudrevolution/veeamnetapptoolkit)
[![Documentation Status](https://readthedocs.org/projects/veeamnetapptoolkit/badge/?version=latest)](https://veeamnetapptoolkit.readthedocs.io/en/latest/?badge=latest)


## About

### Project Owner

Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)

my cloud-(r)evolution [mycloudrevolution.com](http://mycloudrevolution.com/)

### Project Repository

[GitHub - VeeamNetAppToolkit](https://github.com/mycloudrevolution/vSphereNetAppToolkit)

### Project Documentation

[Read the Docs - VeeamNetAppToolkit](https://veeamnetapptoolkit.readthedocs.io)

[Wiki- VeeamNetAppToolkit](https://github.com/mycloudrevolution/VeeamNetAppToolkit/wiki)

### Project Description

This Module helps to automate some basic steps that interact between Veeam and NetApp ONTAP.

## Prequirements

For further details see [Wiki - Prequirements](https://github.com/mycloudrevolution/VeeamNetAppToolkit/wiki#prerequirements)

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

[Wiki- New-VeeamNetappVolume](https://github.com/mycloudrevolution/VeeamNetAppToolkit/wiki/New-VeeamNetappVolume)