fastfetch --format json | jaq 'map(select(.error == null and (.result != null and .result != [])))' --compact-output
