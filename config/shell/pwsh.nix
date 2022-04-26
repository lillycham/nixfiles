{
  home.file.".config/powershell/Microsoft.Powershell_profile.ps1".text = ''
    Invoke-Expression(&starship init powershell)
    Write-Host 'Welcome to PowerShell' (Get-Host).Version '.'
  '';
}
