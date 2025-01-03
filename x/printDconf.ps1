#!/bin/env pwsh
$ErrorActionPreference = 'Stop'

dconf dump / | bat --paging never --language ini --decorations never
