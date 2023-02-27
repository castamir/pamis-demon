. "$PSScriptRoot\src\utils.ps1"
. "$PSScriptRoot\src\ares.ps1"

$config = Parse-IniFile "$PSScriptRoot\examples\config.ini"
$job = Parse-IniFile "$PSScriptRoot\examples\job.ini"

switch ($job.uloha.typ)
{
    "ares" {
        DAres $job.parametry $config
    }
}

