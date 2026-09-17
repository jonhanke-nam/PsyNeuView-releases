# Changelog

Every released version of the PsyNeuView Mac app, newest first.

Generated from the published releases by `scripts/generate-changelog.sh`
in the PsyNeuView-MacApp repository. Do not edit by hand -- the next
release overwrites it. Release notes are written as the annotated tag
message when a version is cut.

Downloads for every version: https://github.com/jonhanke-nam/PsyNeuView-releases/releases

## PsyNeuView 0.5.12 — works alongside your editor, and starts without the wait

_Released 2026-09-17 · [`v0.5.12`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.12)_

Most of this release is about PsyNeuView and a Python editor being open on the
same file at once, and about the app being honest when it cannot do something.

Sync says what it is doing. A small indicator states whether the file on
disk is being watched, whether a change just arrived, or whether a decision is
waiting on you. Before, sync was invisible: when it worked you saw the canvas
change, and when it stopped you saw nothing at all.

Saving cannot quietly overwrite someone else's work. If the file changed on
disk since PsyNeuView loaded it, the save is refused and you are offered the
same choice an external edit raises. Neither version is lost.

A half-finished file no longer blanks the canvas. A model under edit is
broken for much of the time it is being edited. Rather than tearing the graph
down and rebuilding it a keystroke later, the last version that built is held,
and labelled as such. The banner offers a diff against that version — mid-edit,
"what did I just change" is usually a faster route to the problem than the
syntax error.

Layout keeps what you decided. A node dropped from the palette lands where
you dropped it. Edges you shaped by hand survive a reload. Positions for nodes
that no longer exist are cleared, so a reused name cannot inherit a stranger's
coordinates. A rename you perform carries the node's position with it. And the
inspector says which parts of the arrangement are yours and which were
computed — the computed ones adapt as the model changes, and now you can tell
them apart.

Recurrent models lay out sensibly. Ranking a graph with cycles has no
answer; edges that close a cycle no longer get a vote in placement. Six of the
ten bundled reference models are recurrent, so this is the common case.

Starting up stops re-downloading PsyNeuLink. Launching used to re-clone the
entire PsyNeuLink repository even when nothing upstream had changed. pip cannot
cache a git branch URL, so "install from devel" means a fresh clone every time —
measured at about 105 seconds of a 122-second start. It now asks first: one
query returns the branch's current commit, the installed build already records
the commit it was made from, and if they match there is nothing to download.
The check takes roughly a third of a second.

This applies to installs that track a git branch, which is the default and the
slow case. A PyPI install was never affected, since pip can cache that.

Smaller things. An auto bend now explains why it cannot be deleted instead
of ignoring the double-click, and attachment dots respond to hover the way bend
handles do. The version reported in Settings no longer goes stale when a release
changes only the version string — an error the previous release's
skip-the-reinstall fix had quietly introduced.

Bundles PsyNeuView 0.5.6.

## PsyNeuView 0.5.11 — starts up without the two-minute pause

_Released 2026-09-17 · [`v0.5.11`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.11)_

An update that changed nothing but a version string used to trigger a
full dependency reinstall, which re-clones PsyNeuLink from a git branch
and cannot be served from pip's cache. One boot spent 2m02s on work that
was not needed. Reinstalls now happen when dependencies actually move
(#144).

While it waited, the log said 'Cannot open window: server port not
assigned yet' — accurate, not an error, and the last line for minutes, so
a slow start read as a hang. It now says what it is waiting on, and warns
before the slow step rather than after (#146).

The update also only looked at the last commit of a pull that routinely
brings several, so a frontend change could arrive without triggering its
rebuild (#145).

Keyboard shortcuts: the backend was never told it had been launched by
the Mac app, so Settings applied browser rules inside a WKWebView and
refused Cmd+W, Cmd+T, Cmd+N and Cmd+L as unreachable. They are bindable
now, where they do in fact work (#59).

Bundles PsyNeuView 0.5.5, which reports its own version correctly.

Note: updating from 0.5.10 still uses the old updater, so this install is
the last slow one.

## PsyNeuView 0.5.10 — no longer quits when you decline to move it

_Released 2026-09-16 · [`v0.5.10`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.10)_

A crash fix that matters if you run the app from the disk image, and a
handful of changes to Settings and setup.

Crash when declining to move the app
  If you ran PsyNeuView from somewhere other than your Applications folder —
  straight from the mounted disk image, say — the app asked whether to move
  itself. Answering "Continue Without Moving" quit the app instantly.

  It now continues, as it always should have. Anyone who hit this and assumed
  the app was broken can try again.

The About window
  It is a real window now: drag to resize, pinch to zoom, or use Command-plus
  and Command-minus, with Command-zero to reset. The size you choose is
  remembered.

  The text is also simply larger, which was the original complaint.

Choosing which PsyNeuLink to use
  Setup now asks, instead of only offering the choice afterwards: the latest
  development version, the official release, or a checkout you already have.
  Ignoring the question gives you what you got before.

  After setup, the source can be changed from either Settings window — the
  app's own, or the gear icon inside PsyNeuView. Previously the gear icon
  refused and sent you to the app's Preferences; worse, a choice made in one
  place could be silently undone by the other later.

  Changing it in the app's Settings now applies immediately. It used to save
  the setting and do nothing until an update happened to run, which for some
  changes meant never.

How old your PsyNeuLink is
  Settings showed the branch name and nothing else, which reads as current
  however far behind the installed copy has drifted. It now says, for example,
  "111 commits behind devel, newest from 2026-07-29".

  It also reports whether PsyNeuLink still works rather than only what version
  it claims to be — an install pointed at a folder you have since moved looks
  healthy by version alone.

Installing into a folder that is not empty
  Setup warns before installing into a folder that already has your files in
  it, rather than only recognising its own previous installs.

## PsyNeuView 0.5.9 — easier to find your way around, and models that would not edit now do

_Released 2026-09-16 · [`v0.5.9`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.9)_

Mostly about finding your way around, plus a fix for models the canvas
would not edit.

Models that could not be edited, now can
  Some models could not be edited from the canvas at all. Clicking a node and
  changing it did nothing, or refused, and there was no obvious reason why —
  the model looked ordinary and the code was fine.

  The cause was narrow and entirely ours. PsyNeuView recognised a node only
  when it was written with the pnl. prefix:

      hidden = pnl.TransferMechanism(name="hidden")

  Written any other ordinary way — a bare constructor after "from psyneulink
  import *", a different module alias, a submodule path — the node was invisible
  to the editor, even though everything else about it worked.

  Measured across the bundled models and PsyNeuLink's own example scripts, 80
  of 160 files contained nodes hidden this way. Several contained nothing but:
  the canvas could not address a single node in them.

  If you tried to edit a model, found it unresponsive, and concluded it was
  unsupported — it probably was not. Worth another look.

Saying which nodes cannot be edited, and why
  A few nodes genuinely cannot be changed from the graph, and the app used to
  imply it without saying so: the diagnostics bar would report "5 mechanisms —
  4 editable" and never name the fifth.

  Now it names it, and says which kind it is. A node you wrote inside another
  component's settings has no line of its own for the graph to rewrite, but you
  can still edit it in the code. A node PsyNeuLink builds for you — learning,
  control and memory machinery — has no source at all, so there is nothing to
  edit anywhere. The advice differs because the situations do.

The Open menu
  The menu now opens short, with each section folded. Drag a section heading to
  reorder it, or use Settings, where there is also a way back to the original
  order. Your own models come first, then PsyNeuLink's.

The Components palette
  The palette also starts with its categories closed rather than showing about
  forty rows before you have chosen anything. Click a heading to open one.

  The fold triangles in both the palette and the Open menu were small enough to
  read as decoration. They are bigger now, and the same in both places.

View only, enforced at the write
  The view-only lock from 0.5.8 is now checked when the file is written, not
  only when the request arrives. A locked model stays locked on every path that
  could change it.

## PsyNeuView 0.5.8 — a model can be marked view only

_Released 2026-09-16 · [`v0.5.8`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.8)_

Two changes, both about the canvas editing your model file.

View only
  A model can now be marked view only, and then the graph cannot change it.
  The setting travels with the model rather than with you, so a model set up
  for teaching or shared with someone stays locked when they open it. Use the
  editable / view only button in the toolbar, beside the format badge.

  The code editor is unaffected. This is about the graph as a way of changing
  the model, not about making the file read-only — you can still edit the code
  of a view-only model.

Where a new node gets written
  Adding a node from the canvas used to append the new declaration at the end
  of the file. Usually harmless, occasionally wrong: on a file ending inside an
  indented block it produced invalid Python, and even when it worked, the node
  landed after the Composition that used it.

  New nodes now go just before the Composition. A related fault is fixed too:
  any comment containing the word "Mechanisms" was being treated as a section
  heading, including one inside a function, which could put a new node in the
  middle of an existing call.

  Checked against PsyNeuLink's own example scripts as well as the bundled
  models: adding a node now works on all 103 tested, and lands in a sensible
  place in every one.

## PsyNeuView 0.5.7 — graph edits actually reach the file

_Released 2026-09-16 · [`v0.5.7`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.7)_

Brings the app up to PsyNeuView 0.5.1. Everything Samuel Anderson and Jon
Cohen reported is in this build — 0.5.6 fixed the installer and the app
shell, but bundled a PsyNeuView from before that work landed.

Graph edits reach the file
  Deleting a node could silently do nothing: the file came back unchanged
  and was reported as saved, so the canvas showed an edit the file never
  received. It now refuses and explains why. Each action in History shows
  how it changed the code, and an edit that changed nothing says so.

Errors you can act on
  Click a model error to jump to the line it happened on, from either the
  editor banner or the graph. A failed run reports the reason it failed
  instead of a wall of warnings, with the warnings still available behind a
  toggle. A successful run now shows what PsyNeuLink said about the model,
  which previously you only ever saw by accident.

Your model file is safe from us
  A parenthesis inside a comment could throw off the code writers and leave
  a file that no longer parses. Beyond fixing that, every edit PsyNeuView
  composes is now checked before it lands: if it would produce invalid
  Python the write is refused and the file is left exactly as it was.

Opening a model
  A model that calls show_graph() no longer renders a PDF and throws it over
  the app.

Undo
  Undo no longer walks back into a previously loaded model, and no longer
  discards your layout along with the edit.

Keyboard shortcuts
  Cmd+I shows the Inspector. Settings lists every shortcut and lets you
  rebind them; a combination already in use is refused by name rather than
  quietly failing later.

Also in this release
  The Mac menu no longer binds Cmd+X to Stop Services or Cmd+S to Start
  Services, and there is a proper Edit menu with Cut, Copy, Paste and
  Select All.

## PsyNeuView 0.5.6 — your saved models are safe from the app's own cleanup

_Released 2026-09-15 · [`v0.5.6`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.6)_

Fixes for problems found by people actually installing and using 0.5.2–0.5.5.

Your saved models are safe
  Models saved into the app's models/ folder could be destroyed by the app's
  own cleanup, because that folder lived inside storage the app deletes and
  recreates. They now live in ~/.psyneuview/models, outside anything the app
  removes, and existing models are rescued on first launch rather than left
  where they were. (#1089)

Faster first install
  PsyNeuLink was being downloaded and installed twice: once from PyPI as a
  dependency of the backend, then immediately replaced by the copy from the
  branch you actually chose. The chosen source is now installed first, and the
  backend install leaves it alone. (#115)

No more phantom second app
  A development build left in the source folder could appear in Launchpad and
  Spotlight beside your real install — and being an older build, it behaved
  like the app did before it bundled its own Python. Builds now go somewhere
  Spotlight does not index. This only affected people who build from source.
  (#118)

PsyNeuLink no longer goes quietly stale
  The app installs PsyNeuLink from the Princeton devel branch, but pinned it at
  install time and never mentioned it again — one install was running a
  PsyNeuLink older than the current PyPI release while reporting "devel".
  Settings now shows how far behind it is, and the app offers to refresh it at
  launch. It offers rather than acting: you decide, and you can say "don't ask
  again". The check never delays startup, and if it cannot reach GitHub it says
  so rather than pretending everything is current. (#116)

Also
  The release-freshness check was counting commits against a dormant branch, so
  it reported "up to date" while eight commits sat unreleased.

## PsyNeuView 0.5.5 — recovers from a broken install instead of stopping at one

_Released 2026-09-15 · [`v0.5.5`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.5)_

Launcher-only release; the bundled PsyNeuView stays at 0.5.0.

Two people hit install failures today and neither could get out of it unaided.
This release is mostly about the app getting itself out of trouble, and about
saying what is happening while it does.

- A missing Python environment is rebuilt rather than reported. One install
  found its files intact, found no environment, wrote "run the Setup Wizard" to
  a log nobody had reason to open, and stopped — pointing at a menu item rather
  than anything on screen. Building that environment is what setup does, so the
  app now just does it. Reported by Younes Strittmatter.

- PsyNeuView offers to move itself to your Applications folder when you launch
  it from somewhere else. Its Python environment records where the app lives, so
  running from a disk image or your Downloads folder and moving the app later
  strands about 1.4 GB and breaks the install days after the fact.

- A diagnostic ships with the app, at
  Contents/Resources/diagnose-install.sh, and is published at
  jonhanke-nam.github.io/PsyNeuView-releases/diagnose-install.sh. If something
  goes wrong it reports which build you have, where it is running from, and
  whether the Python environment survived.

- Releases now say what is in them. These notes appear on the download page and
  in the update dialog, which previously offered a version number and no reason
  to install it.

- The release process now measures how long starting actually takes and refuses
  to publish if it approaches the limit the app allows — the failure Samuel
  Anderson reported on 0.5.3 would have been caught before it shipped.

## PsyNeuView 0.5.4 — a slow start is no longer a failure

_Released 2026-09-15 · [`v0.5.4`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.4)_

Launcher-only release; the bundled PsyNeuView stays at v0.5.0.

Reported by Samuel D. Anderson from a 0.5.3 install: the app declared startup
failed eleven seconds before its own backend came up. PsyNeuLink warmed up in
38.67 seconds against a 30-second ceiling, polling stopped at that ceiling so the
recovery went unnoticed, nothing on screen said work was still happening, and the
Try Again button could not act in the state that showed it.

- The ceiling is now ten minutes, with a dead process detected separately, so it
  bounds a hung server rather than a slow one.
- Polling continues until the backend answers.
- Past twenty seconds the window says how long PsyNeuLink has been loading, so a
  slow first run reads as progress rather than a hang.
- Try Again waits instead of refusing.
- uvicorn no longer runs with --reload in a bundled install, where it was
  watching the whole backend tree for changes that never come.

## PsyNeuView 0.5.3 — About reports all three versions

_Released 2026-09-15 · [`v0.5.3`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.3)_

Launcher-only release; the bundled PsyNeuView stays at v0.5.0.

About now names the app, the PsyNeuView bundled with it, and the PsyNeuLink
installed at first run:

  PsyNeuView app 0.5.3
  PsyNeuView 0.5.0, bundled with the app
  PsyNeuLink 0.19.1.0+10.g83cc4165b7, installed from PyPI
  Other PsyNeuLink sources available: PrincetonUniversity, jonhanke-nam

The three move independently, so a bug report that gives only one of them cannot
say what produced the behaviour. PsyNeuLink is described as installed rather than
bundled because it is: it comes from PyPI by default at first run, or from a
branch of PrincetonUniversity/PsyNeuLink, or a local checkout — and which source
it came from changes what you are running.

Also carries the build.yml half of the release-gate fix, which had been verifying
the pip fallback rather than the uv path that ships.

## PsyNeuView 0.5.2 — the app window, and a much faster first run

_Released 2026-09-15 · [`v0.5.2`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.2)_

Launcher-only release; the bundled PsyNeuView stays at v0.5.0.

- A finished install now opens the app rather than the debug log. That was the
  first thing a new user saw after a successful setup, with nothing indicating
  the app was still starting or where to find it. Startup failures now say so in
  the window instead of leaving a spinner running indefinitely. (#96)

- Dependencies install with a bundled uv instead of pip. Measured cold on the
  same machine: 217 seconds against pip's 1032. A rebuild with a warm cache,
  which is what a Python bump costs, takes 33. (#94)

- The release itself now verifies that the bundled install runs — unpack, create
  the environment, install dependencies for real, import them under the hardened
  runtime, and confirm the backend answers — before anything is signed or
  published. 0.5.0 shipped unable to start because nothing asked. (#45)

- Install documentation rewritten for an app that installs nothing: what it
  actually does, and the complete list of where it writes.

## PsyNeuView 0.5.1 — makes the bundled install actually run

_Released 2026-09-15 · [`v0.5.1`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.1)_

0.5.0 shipped the bundling work but could not start from its own install
directory. This is the build to use.

Fixes
- The launch check required a Makefile, which a bundled tree deliberately does
  not ship — the Makefile drives venv creation, npm and the dev servers, none of
  which a bundled install uses. The app refused to start from the directory its
  own setup had just created. (#89)
- The launch-time code updater ran git against a tree with no .git. On a Mac
  without Xcode Command Line Tools, invoking git there pops the developer-tools
  dialog that 0.5.0 had removed from setup. (#87)

Also
- The bundled PsyNeuView is now pinned to its v0.5.0 tag rather than a raw
  commit, so the install reports a real version instead of 0.0.0-dev.463bd6f.

## PsyNeuView 0.5.0 — the self-contained release

_Released 2026-09-15 · [`v0.5.0`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.5.0)_

PsyNeuView and its Python runtime now ship inside the app. A default install
needs no GitHub account, no access to a private repository, no git, no Homebrew
and no Node, and writes nothing outside the app's own directories.

What changed
- CPython 3.14.7 ships in the bundle, signed and notarized, with library
  validation disabled so pip-installed numpy/scipy/torch load under the
  hardened runtime.
- PsyNeuView itself ships as an archive, unpacked to Application Support on
  first run, with its frontend built at release time.
- Homebrew is never installed. Where a developer build needs a tool we don't
  ship, the app says what to install rather than installing it.
- The app resolves its toolchain from its own bundle instead of inheriting the
  user's shell PATH, so a conda or pyenv interpreter can no longer become the
  one the backend is built against.
- GitHub sign-in, when needed at all, uses a GitHub App device flow issuing a
  token restricted to the PsyNeuView repository and expiring in eight hours.
- Updates are checked daily. Installing one still asks first, because an update
  can bump the bundled Python and rebuild the backend environment.

Cloning remains available as an opt-in for working on PsyNeuView itself.

## PsyNeuView 0.4.9 — PsyNeuLink from Princeton devel, and a stale-window fix

_Released 2026-08-19 · [`v0.4.9`](https://github.com/jonhanke-nam/PsyNeuView-releases/releases/tag/v0.4.9)_

Two fixes, one of which changes which PsyNeuLink you get.

- **PsyNeuLink now comes from Princeton's `devel` branch rather than PyPI.** The
  PyPI release trails what PsyNeuView is built against and omits newer library
  models — the Giallanza 2024 EGO study among them — so the PsyNeuLink Library
  menu didn't match the app around it. You can still choose PyPI, another branch,
  or a fork under Preferences ▸ PsyNeuLink Source.

- **Restarting the services no longer leaves a dead window behind.** Restart
  Services opened a fresh window without closing the old one, so you were left
  with two: a working one and one still pointing at the previous server.

