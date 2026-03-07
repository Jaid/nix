# Ensure essential environment variables are set
set --global --export HOME (set -q HOME; and echo $HOME; or echo $HOMEPATH; or echo $USERPROFILE; or echo "/home/$USER"; or echo "/home/$USERNAME"; or echo '/root')
set --global --export USERPROFILE $HOME
set --global --export LOCALAPPDATA (set -q LOCALAPPDATA; and echo $LOCALAPPDATA; or echo "$HOME/.local/share")
set --global --export APPDATA (set -q APPDATA; and echo $APPDATA; or echo "$HOME/.config")
set --global --export TEMP (set -q TEMP; and echo $TEMP; or echo "$HOME/temp")
set --global --export TMP $TEMP

# Define additional custom environment variables
set --global --export reposFolder (set -q reposFolder; and echo $reposFolder; or echo "$HOME/git")
set --global --export userBinFolder (set -q userBinFolder; and echo $userBinFolder; or echo "$HOME/x")
set --global --export foreignReposFolder (set -q foreignReposFolder; and echo $foreignReposFolder; or echo "$HOME/git/.foreign")

# Set case sensitivity and editor preference
set --global --export CASE_SENSITIVE true
set --global --export EDITOR nano

# Disable telemetry for various tools
set --global --export ACCEPT_EULA 1
set --global --export DISABLE_OPENCOLLECTIVE 1
set --global --export DISABLE_TELEMETRY true
set --global --export DOTNET_CLI_TELEMETRY_OPTOUT 1
set --global --export DOTNET_TELEMETRY_OPTOUT 1
set --global --export GH_NO_UPDATE_NOTIFIER 1
set --global --export GLAMOUR_STYLE dark
set --global --export HF_HUB_DISABLE_TELEMETRY 1
set --global --export PIP_DISABLE_PIP_VERSION_CHECK 1
set --global --export POWERSHELL_CLI_TELEMETRY_OPTOUT 1
set --global --export POWERSHELL_TELEMETRY_OPTOUT 1
set --global --export POWERSHELL_UPDATECHECK Off
set --global --export POWERSHELL_UPDATECHECK_OPTOUT 1

# Add userBinFolder to PATH if it exists
if test -d $userBinFolder
  fish_add_path --prepend $userBinFolder
end

# Add foreign repos scripts/bin to PATH if it exists
set --local scriptsBinFolder "$foreignReposFolder/scripts/bin"
if test -d $scriptsBinFolder
  fish_add_path --append $scriptsBinFolder
end

if test -d "$reposFolder/node-scripts/temp/shim"
  fish_add_path --prepend "$reposFolder/node-scripts/temp/shim"
end

# Initialize oh-my-posh
if type --query oh-my-posh > /dev/null
  if test -f ~/.config/oh-my-posh/jaid.omp.yml
    oh-my-posh init fish --config ~/.config/oh-my-posh/jaid.omp.yml | source
  elif test -n "$reposFolder" && test -f "$reposFolder/oh-my-posh-config/src/jaid.omp.yml"
    oh-my-posh init fish --config "$reposFolder/oh-my-posh-config/src/jaid.omp.yml" | source
  end
end
