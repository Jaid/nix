{config, lib, ...} @ input: let
	cfg = input.config.jaidCustomModules.nas.it8625e;
	# The B760MZ-E PRO exposes an ITE IT8625E Super I/O controller. Linux’s
	# in-tree it87 driver still doesn’t support it, so use Frank Crawford’s
	# fork and install it into updates/ so it overrides the stock driver.
	it87Module = config.boot.kernelPackages.callPackage ({fetchFromGitHub, kernel, lib, stdenv}:
		stdenv.mkDerivation rec {
			pname = "it87";
			version = "2026-04-16-20f2f2f";
			src = fetchFromGitHub {
				owner = "frankcrawford";
				repo = "it87";
				rev = "20f2f2f4c92c14fcdd26f60d050e693ad2c30bf8";
				hash = "sha256-o2riPbm75Bez4/SrGV7hB3mlqdxxrwRPdre+3W5y/I0=";
			};
			nativeBuildInputs = kernel.moduleBuildDependencies;
			hardeningDisable = ["pic" "format"];
			dontConfigure = true;
			enableParallelBuilding = true;
			makeFlags = [
				"TARGET=${kernel.modDirVersion}"
				"KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
				"DRIVER_VERSION=${version}"
			];
			installPhase = ''
				runHook preInstall
				install -Dm644 it87.ko "$out/lib/modules/${kernel.modDirVersion}/updates/it87.ko"
				runHook postInstall
			'';
			meta = {
				homepage = "https://github.com/frankcrawford/it87";
				description = "Out-of-tree ITE Super I/O hardware monitoring and fan control driver";
				license = lib.licenses.gpl2Plus;
				platforms = lib.platforms.linux;
			};
		}) {};
in {
	options.jaidCustomModules.nas.it8625e.enable = lib.mkOption {
		type = lib.types.bool;
		default = false;
		description = "Enable the patched IT8625E hwmon and PWM driver for the NAS";
	};

	config = lib.mkIf cfg.enable {
		boot.kernelModules = ["it87"];
		boot.extraModulePackages = [it87Module];
		boot.extraModprobeConfig = ''
			options it87 ignore_resource_conflict=1
		'';
	};
}
