$jsonFile = "input.json"
$outputFile = "config.txt"
$customText = "B7XQfIFBPJD7jujtfFuLBjg5j5NJjJLz"

if (-Not (Test-Path $jsonFile)) {
    Write-Host "Hata: JSON dosyasý bulunamadý: $jsonFile"
    exit 1
}
try {
    $content = Get-Content $jsonFile -Raw
    $encodedContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
    $encodedContent | Out-File -FilePath $outputFile -Encoding ASCII
} catch {
    Write-Host "Hata: JSON dosyasýný þifrelerken bir hata oluþtu."
    exit 1
}

$lines = Get-Content $outputFile
$tempFile = "$outputFile.tmp"

foreach ($line in $lines) {
    if ($line -ne "-----BEGIN CERTIFICATE-----" -and $line -ne "-----END CERTIFICATE-----") {
        Add-Content -Path $tempFile -Value $line
    }
}

$rawText = Get-Content $tempFile -Raw
$checksum = 0

foreach ($char in $rawText.ToCharArray()) {
    $checksum = $checksum -bxor [byte][char]$char
}

$checksumHex = "{0:X2}" -f $checksum

$finalLine = "==${customText}:${checksumHex}"
Add-Content -Path $tempFile -Value $finalLine

Move-Item -Path $tempFile -Destination $outputFile -Force

$finalContent = Get-Content $outputFile
$finalContent | Out-File -FilePath $outputFile -Encoding ASCII -Force

Write-Host "JSON dosyasý baþarýyla düzenlendi ve $outputFile dosyasýna kaydedildi."
