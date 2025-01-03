$env:HOME = $env:HOME ?? $env:HOMEPATH ?? $env:USERPROFILE ?? "/home/$env:USER" ?? "/home/$env:USERNAME" ?? '/root'
$env:USERPROFILE = $env:HOME
$env:LOCALAPPDATA = $env:LOCALAPPDATA ?? "$env:HOME/.local/share"
$env:APPDATA = $env:APPDATA ?? "$env:HOME/.config"
$env:TEMP = $env:TEMP ?? "$env:HOME/temp"
$env:TMP = $env:TEMP

$env:reposFolder = $env:reposFolder ?? "$env:HOME/git"
$userBinFolder = $userBinFolder ?? "$env:HOME/x"
$foreignReposFolder = $foreignReposFolder ?? "$env:HOME/git/.foreign"

$env:CASE_SENSITIVE = 'true'
$env:EDITOR = 'nano'

$env:ACCEPT_EULA = '1'
$env:DISABLE_TELEMETRY = 'true' # https://github.com/Mintplex-Labs/anything-llm/blob/5a3d55db671359613a5d68d98eb7166ca6db4188/server/models/telemetry.js#L26
$env:DISABLE_OPENCOLLECTIVE = '1' # https://github.com/WebReflection/lightercollective#disabling-this-message
$env:GH_NO_UPDATE_NOTIFIER = '1' # https://cli.github.com/manual/gh_help_environment
$env:GLAMOUR_STYLE = 'dark'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_TELEMETRY_OPTOUT = '1'
$env:HF_HUB_DISABLE_TELEMETRY = '1'
$env:PIP_DISABLE_PIP_VERSION_CHECK = '1'
$env:POWERSHELL_CLI_TELEMETRY_OPTOUT = '1'
$env:POWERSHELL_TELEMETRY_OPTOUT = '1'
$env:POWERSHELL_UPDATECHECK = 'Off'
$env:POWERSHELL_UPDATECHECK_OPTOUT = '1'

if (Test-Path $userBinFolder) {
  $env:PATH = "${userBinFolder}:$env:PATH"
}

$scriptsBinFolder = "$foreignReposFolder/scripts/bin"
if (Test-Path $scriptsBinFolder) {
  $env:PATH = "$env:PATH:${scriptsBinFolder}"
}

$nodeBinFolder = ""

& oh-my-posh init pwsh --config ~/.config/oh-my-posh/jaid.omp.yml | Invoke-Expression
