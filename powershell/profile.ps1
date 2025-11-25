Import-Module PSReadLine
Import-Module PSFzf

Set-Location $HOME

Set-PSReadlineOption -EditMode vi

#Fuzzy finder PSReadline integration
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Add usersProg to PATH if not already present
$usersProgPath = "$env:USERPROFILE\.local\bin"
if ($env:Path -notlike "*$usersProgPath*") {
    $env:Path += ";$usersProgPath"
}

# Oh-My-Posh Prompt Configuration (Material Theme)
$configPath = "$env:USERPROFILE\.config\oh-my-posh\config.json"
if (Test-Path $configPath) {
    oh-my-posh init pwsh --config $configPath | Out-String | Invoke-Expression
} else {
    Write-Warning "Oh-My-Posh config not found at $configPath"
}


########### HELPING FUNCTIONS ###############
function Get-Docker-Volume-Path {
  [CmdletBinding()]
  param(
      [Parameter()]
      [string]$h,
      [Parameter()]
      [string]$g
  )
  if (-Not $h){
    $h = (Get-Location).ToString()
  }
  if (-Not $g){
    $g = "/workdir"
  }
  Write-Host ("-v {0}:{1}" -f $h.ToLower().replace("\","/"),$g.ToLower().replace("\","/"))

}
