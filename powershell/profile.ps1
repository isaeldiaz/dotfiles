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

# Dracula readline configuration. Requires version 2.0, if you have 1.2 convert to `Set-PSReadlineOption -TokenType`
Set-PSReadlineOption -Color @{
    "Command" = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator" = [ConsoleColor]::Magenta
    "Variable" = [ConsoleColor]::White
    "String" = [ConsoleColor]::Yellow
    "Number" = [ConsoleColor]::Blue
    "Type" = [ConsoleColor]::Cyan
    "Comment" = [ConsoleColor]::DarkCyan
}


# Oh-My-Posh Prompt Configuration
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\config.json" | Out-String | Invoke-Expression


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
