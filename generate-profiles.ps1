# Script to automatically Generate .dcp Profiles out of Standard Adobe Profiles 
# as delivered with a Lightroom Classic installation
# Author: Jan Lorenz, 2019

param(
    [Parameter(Mandatory=$true)][string]$dcptool
)

if (-Not (Test-Path $dcptool)) {
    "DCPTOOL does not exist at $dcptool"
    exit 1
}

# List all Adobe Standard Profiles
$standardProfilePath = Join-Path -Path $Env:PROGRAMFILES -ChildPath '\Adobe\Adobe Lightroom Classic\Resources\CameraProfiles\Adobe Standard'
$standardProfiles = Get-ChildItem -Path "$standardProfilePath"

# Read the lookup table values
$fujiLookupPath = Join-Path -Path $PSScriptRoot -ChildPath "dcp"
$fujiLookups = Get-ChildItem -Path "$fujiLookupPath"

# Prepare Temporary output directory
$tmpStandardXml = Join-Path -Path $PSScriptRoot -ChildPath "stdxml"
if ((Test-Path $tmpStandardXml)) {
   Remove-Item -Path $tmpStandardXml -recurse
}
New-Item -Path "$PSScriptRoot" -Name "stdxml" -ItemType "directory" | Out-Null

$tmpOutBase = Join-Path -Path $PSScriptRoot -ChildPath "tmpxml" 
if ((Test-Path $tmpOutBase)) {
    Remove-Item -Path $tmpOutBase -recurse
}
New-Item -Path "$PSScriptRoot" -Name "tmpxml" -ItemType "directory"  | Out-Null

# Prepare final output directory
$dcpOutBase = Join-Path -Path $PSScriptRoot -ChildPath "dcpout" 
if ((Test-Path $dcpOutBase)) {
    Remove-Item -Path $dcpOutBase -recurse
}
New-Item -Path "$PSScriptRoot" -Name "dcpout" -ItemType "directory"  | Out-Null

# Iterate over the Profiles, and convert them to XML into a temporary sub directory
foreach($standardProfile in $standardProfiles) {
    $fullPath = $standardProfile.FullName
    $profileName = $standardProfile.Basename
    $outXml = (Join-Path -Path $tmpStandardXml -ChildPath "$profileName.xml" )

    "Converting $profileName"
    Invoke-Expression ("& $dcptool", "-d", "'$fullPath'", "'$outXml'" -join " ")

    foreach($lookupFile in $fujiLookups) {

        $fujiProfileName = $lookupFile.Basename

        # Read the converted xml file using a parser
        [xml]$profileXml = Get-Content $outXml

        # Read the lookup file (also XML)
        [xml]$lookupXml = Get-Content $lookupFile.FullName

        # Generate the new Profile
        # replace the `<LookTable>` and `<ToneCuve>` xml tags with the ones from the film look text file
        # `<DefaultBlackRender>` should be set to `1`
        # `<ProfileLookTableEncoding>` should be set to `1`
        # change `<ProfileName>`
        $profileXml.dcpData.ProfileName = "Fuji Adobe Standard $fujiProfileName"
        $profileXml.dcpData.DefaultBlackRender="1"
        $profileXml.dcpData.ProfileLookTableEncoding="1"

        $lookTableNode = $profileXml.dcpData.SelectSingleNode("LookTable")
        if($lookTableNode -ne $null) {
            "-- replacing LookTable data"
            $profileXml.dcpData.ReplaceChild($profileXml.ImportNode($lookupXml.profiledata.LookTable, $true), $lookTableNode) | Out-Null
        } else {
            "-- adding LookTable data"
            $profileXml.dcpData.AppendChild($profileXml.ImportNode($lookupXml.profiledata.LookTable, $true)) | Out-Null
        }

        $toneCurveNode = $profileXml.dcpData.SelectSingleNode("ToneCurve")
        if($toneCurveNode -ne $null) {
            "-- replacing ToneCurve data"
            $profileXml.dcpData.ReplaceChild($profileXml.ImportNode($lookupXml.profiledata.ToneCurve, $true), $toneCurveNode)  | Out-Null
        } else {
            "-- adding ToneCurve data"
            $profileXml.dcpData.AppendChild($profileXml.ImportNode($lookupXml.profiledata.ToneCurve, $true))  | Out-Null
        }

        # Prepare Temporary and final output folder
        $profileDir = Join-Path -Path $tmpOutBase -ChildPath "$profileName"
        if (-Not (Test-Path $profileDir)) {
            New-Item -Path "$tmpOutBase" -Name "$profileName" -ItemType "directory"  | Out-Null
        }
        $dcpDir = Join-Path -Path $dcpOutBase -ChildPath "$profileName"
        if (-Not (Test-Path $dcpDir)) {
            New-Item -Path "$dcpOutBase" -Name "$profileName" -ItemType "directory"  | Out-Null
        }


        $outTmpXmlFile = Join-Path -Path "$profileDir" -ChildPath "$profileName $fujiProfileName.xml"
        $profileXml.Save($outTmpXmlFile)

        # Use dcptool to generate the final dcp output

        $outDcpFile = Join-Path -Path "$dcpDir" -ChildPath "$profileName $fujiProfileName.dcp"

        "Created Profile $outDcpFile"

        Invoke-Expression ("& $dcptool", "-c", "'$outTmpXmlFile'", "'$outDcpFile'" -join " ")
    }
}

"DONE"