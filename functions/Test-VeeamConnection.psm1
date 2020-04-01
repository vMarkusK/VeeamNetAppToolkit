function Test-VeeamConnection {

    try {
        $VBRServerSession = Get-VBRServerSession
    }
    catch {
        Throw "No Valid Veeam Connection."    
    }

    if ($VBRServerSession.Count -lt 1) {
        Throw "No Valid Veeam Connection."      
    }
}