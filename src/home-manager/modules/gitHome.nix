{config, lib, ...}: let
  gitDirectory = if lib.hasPrefix "/" config.gitHome.folder then config.gitHome.folder else "${config.home.homeDirectory}/${config.gitHome.folder}";
  gitCommand = "${config.programs.git.package}/bin/git";
  sshCommand = "ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new";
  getRepositoryName = repository: builtins.elemAt (lib.splitString "/" repository) 1;
  repositoryNames = map getRepositoryName config.gitHome.initialRepos;
  cloneRepository = repository: let
    repositoryName = getRepositoryName repository;
    repositoryDirectory = "${gitDirectory}/${repositoryName}";
  in ''
    $DRY_RUN_CMD mkdir --parents ${lib.escapeShellArg gitDirectory}
    repoDirectory=${lib.escapeShellArg repositoryDirectory}
    if [ ! -e "$repoDirectory" ]; then
      if ! $DRY_RUN_CMD env GIT_SSH_COMMAND=${lib.escapeShellArg sshCommand} ${lib.escapeShellArg gitCommand} clone ${lib.escapeShellArg "git@github.com:${repository}.git"} "$repoDirectory"; then
        $DRY_RUN_CMD rm --recursive --force "$repoDirectory"
        $DRY_RUN_CMD ${lib.escapeShellArg gitCommand} clone ${lib.escapeShellArg "https://github.com/${repository}.git"} "$repoDirectory"
      fi
    else
      ${lib.optionalString config.gitHome.pull ''
        if ${lib.escapeShellArg gitCommand} -C "$repoDirectory" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          if [ -z "$( ${lib.escapeShellArg gitCommand} -C "$repoDirectory" status --porcelain --untracked-files=normal )" ]; then
            if ${lib.escapeShellArg gitCommand} -C "$repoDirectory" rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" >/dev/null 2>&1; then
              $DRY_RUN_CMD env GIT_SSH_COMMAND=${lib.escapeShellArg sshCommand} ${lib.escapeShellArg gitCommand} -C "$repoDirectory" pull --ff-only
            fi
          fi
        fi
      ''}
    fi
  '';
in {
  options.gitHome = {
    folder = lib.mkOption {
      type = lib.types.str;
      default = "git";
      description = "Git home folder. Relative paths are resolved against the home directory, absolute paths are used as-is.";
    };
    pull = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether existing clean repositories should be pulled during activation.";
    };
    initialRepos = lib.mkOption {
      type = lib.types.listOf (lib.types.strMatching "[^/]+/[^/]+");
      default = [];
      description = "Initial GitHub repositories to clone into the git home if they are missing.";
    };
  };
  config = {
    home.activation.createGitHome = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir --parents ${lib.escapeShellArg gitDirectory}
    '';
    assertions = lib.mkIf (config.gitHome.initialRepos != []) [
      {
        assertion = builtins.length repositoryNames == builtins.length (lib.lists.unique repositoryNames);
        message = "gitHome.initialRepos cannot contain multiple repositories with the same name because they would collide under ${gitDirectory}.";
      }
    ];
    home.activation.cloneInitialRepos = lib.mkIf (config.gitHome.initialRepos != []) (lib.hm.dag.entryAfter ["createGitHome"] ''
      ${lib.concatMapStringsSep "\n" cloneRepository config.gitHome.initialRepos}
    '');
  };
}
