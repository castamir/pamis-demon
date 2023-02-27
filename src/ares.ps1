function DAres
{
    param (
        $job,
        $config
    )

    PROCESS {
        try
        {
            # todo test $job.ico exists
            $xml = DAres_GetXml($job.ico, $config)
            $aresData = DAres_ParseXml($xml)
            DAres_Print($aresData)
        }
        catch
        {
            $error
        }
    }
}

function DAres_GetXml
{
    param (
        $ico,
        $config
    )

    PROCESS {
        # tmp file name for encoding change purposes
        $tmpFileName = "$PSScriptRoot\tmp.xml"
        $URL = "https://wwwinfo.mfcr.cz/cgi-bin/ares/darv_std.cgi?ico=${ico}"
        $enc = "Default"
        if ($config.system.os -ne "windows")
        {
            $enc = "Windows-1252"
        }

        try
        {
            $AresResponse = Invoke-WebRequest -Uri $URL
        }
        catch
        {
            throw [System.ApplicationException]::New("Nepodarilo se spojit s ARES. Zkontrolujte volanou URL (${URL}) a sve pripojeni k internetu.")
        }

        if ($AresResponse.StatusCode -ne 200)
        {
            throw [System.IO.FileNotFoundException]::New('Nepodarilo se ziskat informace z ARES.')
        }

        # change encoding via tmp file
        $AresResponse.Content | Set-Content -Path $tmpFileName -Encoding $enc
        $xmlContent = Get-Content -Path $tmpFileName
        #        Remove-Item $tmpFileName

        # convert plain text to XML object
        $xml = New-Object -TypeName System.Xml.XmlDocument
        $xml.LoadXml($xmlContent)

        return $xml
    }
}


function DAres_ParseXml
{
    param (
        $xml
    )

    PROCESS {
        # kontrola, zda ARES nalezl data
        if ($xml["are:Ares_odpovedi"].Odpoved.Error)
        {
            throw [System.ArgumentException]::New("ARES vratil chybovy kod ${$xml["are:Ares_odpovedi"].Odpoved.Error.Error_kod} (${$xml["are:Ares_odpovedi"].Odpoved.Error.Error_text}).")
        }

        [hashtable]$data = @{ }
        $data.Obchodni_firma = $xml["are:Ares_odpovedi"].Odpoved.Zaznam.Obchodni_firma
        $data.ICO = $xml["are:Ares_odpovedi"].Odpoved.Zaznam.ICO
        Return $data
    }
}

function DAres_Print
{
    param (
        $aresData
    )

    PROCESS {
        $fileName = "$PSScriptRoot\..\dst\ares.ini"
        $template = @"
ICO={0}
Obchodni_firma={1}
"@
        $content = $template -f $aresData.ICO, $aresData.Obchodni_firma

        # TODO allow configurable encoding i.e. '-Encoding "Windows-1252"'
        $content | Set-Content -Path $fileName
    }
}
