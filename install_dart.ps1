$url = "https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-windows-x64-release.zip"
$dest = "H:\dartsdk.zip"
Write-Host "Downloading Dart SDK..."
Invoke-WebRequest -Uri $url -OutFile $dest
Write-Host "Extracting Dart SDK to H:\..."
Expand-Archive -Path $dest -DestinationPath "H:\" -Force
Write-Host "Adding H:\dart-sdk\bin to User PATH..."
$oldPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($oldPath -notlike '*H:\dart-sdk\bin*') {
    $newPath = $oldPath + ';H:\dart-sdk\bin'
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "PATH updated successfully."
} else {
    Write-Host "PATH already contains H:\dart-sdk\bin."
}
Write-Host "Cleaning up zip file..."
Remove-Item -Path $dest -Force
Write-Host "Dart SDK Installation Complete!"
H:\dart-sdk\bin\dart.exe --version
