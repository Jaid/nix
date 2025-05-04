import {$} from 'execa'
import * as path from 'node:path'
import {temporaryDirectoryTask} from 'tempy'
const hostname = 'tower-vm'
await temporaryDirectoryTask(async tempFolder => {
  const tempDiskFile = path.join(tempFolder, 'disk.qcow2')
  const tempLinkFolder = path.join(tempFolder, 'link')
  const flake = `/home/jaid/git/nix#nixosConfigurations.${hostname}.config.system.build.vm`
  await $`sudo nix build ${flake} --option auto-optimise-store true --option accept-flake-config true --out-link ${tempLinkFolder}`
  const outputExecutableFile = path.join(tempLinkFolder, 'bin', `run-${hostname}-vm`)
  await $({
    env: {
      TMPDIR: tempFolder,
      NIX_DISK_IMAGE: tempDiskFile,
    }
  })`${outputExecutableFile} -m 4G`
})
