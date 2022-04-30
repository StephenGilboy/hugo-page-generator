param($ValuesCsvPath, $ArchtypePath, $WritePath)

$Csv = Import-Csv -Path $ValuesCsvPath;
$Archtype = Get-Content -Path $ArchtypePath;

$Csv | ForEach-Object {
    $entry = $_;
    $fileName = ($entry.name, ".md") -join "";
    $date = (Get-Date).ToString("o");
    $page = $Archtype.Replace("{{ date }}", $date);
    $_.PSObject.Properties | Select-Object -Expand name | ForEach-Object {
        $propName = $_
        $value = $entry | Select-Object -ExpandProperty $propName
        $page = $page.Replace("{{ ${propName} }}", $value);
        $page = $page.Replace("{{ ${propName} | Lower }}", $value.ToLower());
        $page = $page.Replace("{{ ${propName} | Upper }}", $value.ToUpper());
        $page = $page.Replace("{{ ${propName} | Dashed }}", $value.ToLower().Replace(" ", "-"));
    }
    $ValidWritePath = Test-Path -Path $WritePath;
    if ($False -eq $ValidWritePath) {
        New-Item -ItemType Directory -Force -Path $WritePath;
    }
    Set-Content -Path "${WritePath}\${fileName}" -Value $page;
}
