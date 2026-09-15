#!/bin/bash
#
# Report what a PsyNeuView install looks like on this Mac.
#
#   curl -fsSL <raw url> | bash          — or —
#   bash scripts/diagnose-install.sh
#
# Read-only: it looks and prints, and changes nothing.
#
# Exists because install problems are hard to diagnose from a log alone. Two
# reports on the same afternoon needed the same facts — which app is installed
# and from where, whether the Python environment survived, and what the venv
# thinks its interpreter is — and getting them by pasting a shell one-liner
# failed twice, once to zsh aborting on an unmatched glob and once to an editor
# turning a quote into U+201C.
set -uo pipefail

echo "PsyNeuView install report — $(date '+%Y-%m-%d %H:%M:%S')"
echo "macOS $(sw_vers -productVersion) on $(uname -m)"
echo ""

# Where the app is matters: a venv records its interpreter's absolute path, so
# one built while the app ran from the DMG or Downloads points somewhere that
# disappears when the app is moved. (#66)
echo "Application:"
found_app=0
for app in /Applications/PsyNeuView.app \
           "${HOME}/Downloads/PsyNeuView.app" \
           "${HOME}/Desktop/PsyNeuView.app" \
           /Volumes/*/PsyNeuView.app; do
    [ -d "${app}" ] || continue
    found_app=1
    version="$(defaults read "${app}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "?")"
    build="$(defaults read "${app}/Contents/Info" CFBundleVersion 2>/dev/null || echo "?")"
    echo "  ${version} (build ${build})  ${app}"
    case "${app}" in
        /Applications/*) ;;
        *) echo "      ^ not in /Applications — running from here can strand the Python environment" ;;
    esac
done
[ "${found_app}" = "1" ] || echo "  none found"

echo ""
echo "Installed PsyNeuView:"
support="${HOME}/Library/Application Support/PsyNeuView"
found_tree=0
for tree in "${support}"/psyneuview-*; do
    [ -d "${tree}" ] || continue
    found_tree=1
    echo "  $(basename "${tree}")"

    if [ -f "${tree}/BUNDLED_VERSION" ]; then
        echo "      $(tr '\n' ' ' < "${tree}/BUNDLED_VERSION")"
    fi

    # The two files the app needs before it will start. (#89)
    [ -f "${tree}/backend/app/main.py" ] || echo "      MISSING backend/app/main.py"
    [ -f "${tree}/frontend/dist/index.html" ] || echo "      MISSING frontend/dist/index.html"

    venv="${tree}/backend/.venv"
    if [ -f "${venv}/pyvenv.cfg" ]; then
        home_line="$(grep '^home' "${venv}/pyvenv.cfg" | cut -d= -f2- | sed 's/^ *//')"
        echo "      venv interpreter: ${home_line}"
        if [ -d "${home_line}" ]; then
            echo "      that interpreter still exists"
        else
            echo "      THAT INTERPRETER IS GONE — the venv is stranded and needs rebuilding"
        fi
        # A venv with no pip cannot install anything; an interrupted build looks
        # like this. (#106)
        [ -x "${venv}/bin/python" ] || echo "      venv has no python"
        [ -x "${venv}/bin/pip" ] || echo "      venv has no pip"
        size="$(du -sh "${venv}" 2>/dev/null | awk '{print $1}')"
        echo "      venv size: ${size:-unknown}  (a complete one is around 1.4G)"
    elif [ -d "${venv}" ]; then
        echo "      VENV INCOMPLETE — directory exists but has no pyvenv.cfg"
    else
        echo "      NO VENV — nothing installed, or it was removed"
    fi
done
[ "${found_tree}" = "1" ] || echo "  none found (setup has not completed)"

echo ""
echo "Settings:"
echo "  repo path:    $(defaults read PsyNeuView repoPath 2>/dev/null || echo '(not set)')"
echo "  use bundled:  $(defaults read PsyNeuView useBundledApp 2>/dev/null || echo '(default: yes)')"
echo "  PsyNeuLink:   $(defaults read PsyNeuView pnlSource 2>/dev/null || echo '(default: PyPI)')"

echo ""
echo "Machine:"
echo "  free disk:    $(df -h / | tail -1 | awk '{print $4}')  (first setup downloads about 1.4G)"
echo "  git:          $(command -v git >/dev/null && git --version || echo 'not installed')"

echo ""
echo "Paste all of the above into the issue or email. Nothing here is secret —"
echo "it is paths, versions and sizes."
