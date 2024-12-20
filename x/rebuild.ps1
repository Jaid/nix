#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

$thisFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootFolder = Split-Path -Parent $thisFolder

$env:NIXOS_DEBUG = '1'
sudo nixos-rebuild switch --flake "${rootFolder}#$(hostname)" --impure --show-trace
