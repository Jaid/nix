
import {execa} from 'execa'
const options = {
  "auto-optimise-store": "true",
  "extra-experimental-features": "nix-command flakes",
  "accept-flake-config": "true",
  "builders": "ssh://10.0.0.22"
}
const optionsArgs = []
for (const [key, value] of Object.entries(options)) {
  optionsArgs.push("--option", key)
  if (Array.isArray(value)) {
    optionsArgs.push(...value)
  }else{
    optionsArgs.push(value)
  }
}
await execa({
  stdin: "ignore",
  stdout: "inherit",
  stderr: "inherit",
})`sudo nixos-rebuild switch --flake github:Jaid/nix ${optionsArgs}`
