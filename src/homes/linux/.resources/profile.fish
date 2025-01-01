# Ensure essential environment variables are set
set -Ux HOME (set -q HOME; and echo $HOME; or echo $HOMEPATH; or echo $USERPROFILE; or echo "/home/$USER"; or echo "/home/$USERNAME"; or echo '/root')
set -Ux USERPROFILE $HOME
set -Ux LOCALAPPDATA (set -q LOCALAPPDATA; and echo $LOCALAPPDATA; or echo "$HOME/.local/share")
set -Ux APPDATA (set -q APPDATA; and echo $APPDATA; or echo "$HOME/.config")
set -Ux TEMP (set -q TEMP; and echo $TEMP; or echo "$HOME/temp")
set -Ux TMP $TEMP

# Define additional custom environment variables
set -Ux reposFolder (set -q reposFolder; and echo $reposFolder; or echo "$HOME/git")
set -Ux userBinFolder (set -q userBinFolder; and echo $userBinFolder; or echo "$HOME/x")
set -Ux foreignReposFolder (set -q foreignReposFolder; and echo $foreignReposFolder; or echo "$HOME/git/.foreign")

# Set case sensitivity and editor preference
set -Ux CASE_SENSITIVE true
set -Ux EDITOR nano

# Disable telemetry for various tools
set -Ux ACCEPT_EULA 1
set -Ux DISABLE_TELEMETRY true
set -Ux DISABLE_OPENCOLLECTIVE 1
set -Ux GH_NO_UPDATE_NOTIFIER 1
set -Ux GLAMOUR_STYLE dark
set -Ux DOTNET_CLI_TELEMETRY_OPTOUT 1
set -Ux DOTNET_TELEMETRY_OPTOUT 1
set -Ux HF_HUB_DISABLE_TELEMETRY 1
set -Ux PIP_DISABLE_PIP_VERSION_CHECK 1
set -Ux POWERSHELL_CLI_TELEMETRY_OPTOUT 1
set -Ux POWERSHELL_TELEMETRY_OPTOUT 1
set -Ux POWERSHELL_UPDATECHECK Off
set -Ux POWERSHELL_UPDATECHECK_OPTOUT 1

# Add userBinFolder to PATH if it exists
if test -d $userBinFolder
  set -U fish_user_paths $userBinFolder $fish_user_paths
end

# Add foreign repos scripts/bin to PATH if it exists
set scriptsBinFolder "$foreignReposFolder/scripts/bin"
if test -d $scriptsBinFolder
  set -U fish_user_paths $fish_user_paths $scriptsBinFolder
end

if test -d "$reposFolder/node-scripts/temp/shim"
  set -U fish_user_paths $fish_user_paths "$reposFolder/node-scripts/temp/shim"
end

# Initialize oh-my-posh
if type oh-my-posh > /dev/null
  oh-my-posh init fish --config ~/.config/oh-my-posh/jaid.omp.yml | source
end
