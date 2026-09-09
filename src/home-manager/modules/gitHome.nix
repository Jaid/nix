{config, lib, pkgs, ...}: let
  gitDirectory = if lib.hasPrefix "/" config.gitHome.folder then config.gitHome.folder else "${config.home.homeDirectory}/${config.gitHome.folder}";
  gitCommand = "${config.programs.git.package}/bin/git";
  sshCommand = "${pkgs.openssh}/bin/ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10${lib.optionalString (config.gitHome.sshIdentityFile != null) " -o IdentitiesOnly=yes -i ${lib.escapeShellArg config.gitHome.sshIdentityFile}"}";
  getRepositoryName = repository: builtins.elemAt (lib.splitString "/" repository) 1;
  repositoryNames = map getRepositoryName config.gitHome.initialRepos;
  cloneRepository = repository: let
    repositoryName = getRepositoryName repository;
    repositoryDirectory = "${gitDirectory}/${repositoryName}";
  in ''
    repoDirectory=${lib.escapeShellArg repositoryDirectory}
    if [ ! -e "$repoDirectory" ]; then
      if ! gitHomeCloneRepository ${lib.escapeShellArg repository} "$repoDirectory"; then
        gitHomeWarn "Could not clone ${repository}; leaving it absent and continuing Home Manager activation."
      fi
    elif ! "$gitHomeGit" -C "$repoDirectory" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      gitHomeWarn "Expected ${repositoryDirectory} to be a Git worktree, but it is not; leaving it untouched."
    else
      ${lib.optionalString config.gitHome.pull ''
        if ! gitHomeUpdateRepository ${lib.escapeShellArg repository} "$repoDirectory"; then
          gitHomeWarn "Could not refresh ${repository}; keeping the existing checkout and continuing Home Manager activation."
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
      description = "Whether existing clean repositories should be refreshed during activation.";
    };
    retryAttempts = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3;
      description = "Number of rounds to try transient Git network operations before giving up for this activation.";
    };
    retryDelaySeconds = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 2;
      description = "Base delay between Git network retry rounds. Later retries use a linear backoff.";
    };
    sshIdentityFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional SSH identity used by non-interactive GitHub operations during activation.";
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
      gitHomeGit=${lib.escapeShellArg gitCommand}
      gitHomeRetryAttempts=${toString config.gitHome.retryAttempts}
      gitHomeRetryDelaySeconds=${toString config.gitHome.retryDelaySeconds}

      gitHomeWarn() {
        printf 'gitHome: warning: %s\n' "$1" >&2
      }

      gitHomeNetworkGit() {
        $DRY_RUN_CMD env \
          GIT_TERMINAL_PROMPT=0 \
          GIT_SSH_COMMAND=${lib.escapeShellArg sshCommand} \
          "$gitHomeGit" \
          -c http.lowSpeedLimit=1 \
          -c http.lowSpeedTime=15 \
          "$@"
      }

      gitHomeRetrySleep() {
        gitHomeRetryNumber="$1"
        gitHomeDelay=$((gitHomeRetryDelaySeconds * gitHomeRetryNumber))
        if [ "$gitHomeDelay" -gt 0 ]; then
          $DRY_RUN_CMD sleep "$gitHomeDelay"
        fi
      }

      gitHomeCloneRepository() {
        gitHomeRepository="$1"
        gitHomeRepoDirectory="$2"
        gitHomeCloneDirectory="$gitHomeRepoDirectory.gitHome-clone"
        gitHomeAttempt=1
        while [ "$gitHomeAttempt" -le "$gitHomeRetryAttempts" ]; do
          $DRY_RUN_CMD rm --recursive --force "$gitHomeCloneDirectory"
          if gitHomeNetworkGit clone "https://github.com/$gitHomeRepository.git" "$gitHomeCloneDirectory"; then
            if $DRY_RUN_CMD mv "$gitHomeCloneDirectory" "$gitHomeRepoDirectory"; then
              return 0
            fi
          fi

          $DRY_RUN_CMD rm --recursive --force "$gitHomeCloneDirectory"
          if gitHomeNetworkGit clone "git@github.com:$gitHomeRepository.git" "$gitHomeCloneDirectory"; then
            if $DRY_RUN_CMD mv "$gitHomeCloneDirectory" "$gitHomeRepoDirectory"; then
              return 0
            fi
          fi

          $DRY_RUN_CMD rm --recursive --force "$gitHomeCloneDirectory"
          if [ "$gitHomeAttempt" -lt "$gitHomeRetryAttempts" ]; then
            gitHomeWarn "Clone of $gitHomeRepository failed over HTTPS and SSH (round $gitHomeAttempt/$gitHomeRetryAttempts); retrying."
            gitHomeRetrySleep "$gitHomeAttempt"
          fi
          gitHomeAttempt=$((gitHomeAttempt + 1))
        done
        return 1
      }

      gitHomeUpdateRepository() {
        gitHomeRepository="$1"
        gitHomeRepoDirectory="$2"
        if ! gitHomeStatus="$("$gitHomeGit" -C "$gitHomeRepoDirectory" status --porcelain --untracked-files=normal 2>/dev/null)"; then
          gitHomeWarn "Could not inspect $gitHomeRepository; leaving it untouched."
          return 1
        fi
        if [ -n "$gitHomeStatus" ]; then
          return 0
        fi
        if ! gitHomeBranch="$("$gitHomeGit" -C "$gitHomeRepoDirectory" symbolic-ref --quiet --short HEAD 2>/dev/null)"; then
          return 0
        fi
        if ! gitHomeRemote="$("$gitHomeGit" -C "$gitHomeRepoDirectory" config --get "branch.$gitHomeBranch.remote" 2>/dev/null)"; then
          return 0
        fi
        if [ -z "$gitHomeRemote" ] || [ "$gitHomeRemote" = "." ]; then
          return 0
        fi
        if ! gitHomeRemoteUrl="$("$gitHomeGit" -C "$gitHomeRepoDirectory" remote get-url "$gitHomeRemote" 2>/dev/null)"; then
          gitHomeWarn "Could not resolve the upstream remote for $gitHomeRepository; leaving it untouched."
          return 1
        fi
        if ! gitHomeUpstream="$("$gitHomeGit" -C "$gitHomeRepoDirectory" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
          return 0
        fi

        gitHomeAlternateTransport=both
        case "$gitHomeRemoteUrl" in
          https://github.com/*|http://github.com/*)
            gitHomeAlternateTransport=ssh
            ;;
          git@github.com:*|ssh://git@github.com/*)
            gitHomeAlternateTransport=https
            ;;
        esac

        gitHomeFetched=0
        gitHomeAttempt=1
        while [ "$gitHomeAttempt" -le "$gitHomeRetryAttempts" ]; do
          if gitHomeNetworkGit -C "$gitHomeRepoDirectory" fetch --prune "$gitHomeRemote"; then
            gitHomeFetched=1
            break
          fi

          if [ "$gitHomeAlternateTransport" = "https" ] || [ "$gitHomeAlternateTransport" = "both" ]; then
            if gitHomeNetworkGit \
              -c 'url.https://github.com/.insteadOf=git@github.com:' \
              -c 'url.https://github.com/.insteadOf=ssh://git@github.com/' \
              -C "$gitHomeRepoDirectory" fetch --prune "$gitHomeRemote"; then
              gitHomeFetched=1
              break
            fi
          fi

          if [ "$gitHomeAlternateTransport" = "ssh" ] || [ "$gitHomeAlternateTransport" = "both" ]; then
            if gitHomeNetworkGit \
              -c 'url.git@github.com:.insteadOf=https://github.com/' \
              -c 'url.git@github.com:.insteadOf=http://github.com/' \
              -C "$gitHomeRepoDirectory" fetch --prune "$gitHomeRemote"; then
              gitHomeFetched=1
              break
            fi
          fi

          if [ "$gitHomeAttempt" -lt "$gitHomeRetryAttempts" ]; then
            gitHomeWarn "Fetch of $gitHomeRepository failed using the configured and fallback GitHub transports (round $gitHomeAttempt/$gitHomeRetryAttempts); retrying."
            gitHomeRetrySleep "$gitHomeAttempt"
          fi
          gitHomeAttempt=$((gitHomeAttempt + 1))
        done

        if [ "$gitHomeFetched" -ne 1 ]; then
          return 1
        fi
        if ! $DRY_RUN_CMD "$gitHomeGit" -C "$gitHomeRepoDirectory" merge --ff-only "$gitHomeUpstream"; then
          gitHomeWarn "Fetched $gitHomeRepository, but the current branch cannot be fast-forwarded to $gitHomeUpstream; leaving it unchanged."
          return 1
        fi
        return 0
      }

      ${lib.concatMapStringsSep "\n" cloneRepository config.gitHome.initialRepos}
    '');
  };
}
