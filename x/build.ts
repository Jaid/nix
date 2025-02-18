import {execa} from 'execa'
const builderHost = process.env.BUILDER_HOST
const options = {
  "auto-optimise-store": "true",
  "extra-experimental-features": "nix-command flakes",
  "accept-flake-config": "true",
}
if (builderHost) {
  options.builders = `ssh://${builderHost}`
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
})`sudo nixos-rebuild build --flake github:Jaid/nix ${optionsArgs}`
