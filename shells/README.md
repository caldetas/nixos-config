Githook put here: 

        ./.git/hooks/pre-commit
make executable file: 

        chmod +x ./.git/hooks/pre-commit
pre-commit file:

        #!/bin/sh
        # Part 1
        stagedFiles=$(git diff --staged --name-only)
        # Part 2
        echo "Running nixpkgs-fmt. Formatting code..."
        nixpkgs-fmt .
        # Part 3
        for file in $stagedFiles; do
        if test -f "$file"; then
        git add $file
        fi
        done

add forked branch:

        git remote add matthias https://github.com/MatthiasBenaets/nixos-config.git -t master
        git fetch matthias
        git checkout matthias
git hook pre-commit: .git/hooks/pre-commit

        #!/bin/sh
        # Part 1
        stagedFiles=$(git diff --staged --name-only)
        # Part 2
        echo "Running nixpkgs-fmt. Formatting code..."
        nixpkgs-fmt .
        # Part 3
        for file in $stagedFiles; do
        if test -f "$file"; then
        git add $file
        fi
        done