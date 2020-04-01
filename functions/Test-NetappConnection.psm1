function Test-NetappConnection {

    try {
        $NcAggr = Get-NcAggr
    }
    catch {
        Throw "No Valid NetApp Connection."    
    }
}