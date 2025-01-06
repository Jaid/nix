fastfetch --format json | jq 'map(select(.error == null and (.result != null and .result != [])))' --compact-output
