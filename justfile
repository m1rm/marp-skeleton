[private]
default:
    @just --list

install:
    pnpm install

update:
    pnpm update --latest

clean:
    git clean -ffdqx -e /.vscode -e /.idea

[no-cd]
[private]
optimize-png:
    #!/usr/bin/env fish
    if not test -f index.md
        echo 'index.md was found!' >&2
        return 1
    end

    find . -type f -iregex '^.+\.png$' | xargs -r oxipng -o 3 -p --strip all

[no-cd]
[private]
optimize-jpeg:
    #!/usr/bin/env fish
    if not test -f index.md
        echo 'index.md was found!' >&2
        return 1
    end

    find . -type f -iregex '^.+\.jpe?g$' | xargs - jpegoptim -w8 -p -P -s

[no-cd]
optimize: optimize-png optimize-jpeg

[no-cd]
build *args:
    #!/usr/bin/env fish
    if not test -f index.md
        echo 'index.md was found!' >&2
        return 1
    end

    set -l name (path basename "{{ invocation_directory() }}")

    pnpm run --silent marp \
        --pdf \
        --allow-local-files \
        --html \
        --author 'Miriam Mueller' \
        --title "$name" \
        --url (string replace ' ' '+' "https://github.com/m1rm/presentations/src/$name") \
        {{ args }} \
        -o "{{ justfile_directory() }}/dist/$name.pdf" \
        "{{ invocation_directory() }}/index.md"

[no-cd]
open:
    #!/usr/bin/env fish
    if not test -f index.md
        echo 'index.md was found!' >&2
        return 1
    end

    set -l name (path basename "{{ invocation_directory() }}")

    xdg-open "{{ justfile_directory() }}/dist/$name.pdf" > /dev/null 2>&1

[no-cd]
watch: (build '--watch')

optimize-all:
    #!/usr/bin/env fish
    for slide in src/*/index.md
        set -l dirname (path dirname "$slide")
        pushd "$dirname"
            just optimize &
        popd
    end

    wait

build-all:
    #!/usr/bin/env fish
    for slide in src/*/index.md
        set -l dirname (path dirname "$slide")
        pushd "$dirname"
            just build &
        popd
    end

    wait
