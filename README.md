# Profile-sync-daemon
Profile-sync-daemon (psd) is a pseudo-daemon that manages your browser's profile in tmpfs and periodically syncs it back to your physical disc (HDD/SSD). This repository is a fork that allows the use of OpenDoas, in addition to sudo.

## Good advice
Always backup your browser profile(s) before using psd for the first time.

## Supported browsers
* Chromium
* Conkeror
* Epiphany
* Firefox (stable, beta, and aurora)
* Firefox Flatpak (run `flatpak override --user org.mozilla.firefox --filesystem=/run/user/$UID/psd` once to give required access)
* Firefox-trunk (this is an Ubuntu-only browser: http://www.webupd8.org/2011/05/install-firefox-nightly-from-ubuntu-ppa.html)
* Google Chrome (stable, beta, and dev)
* Heftig's version of Aurora (this is an Arch Linux-only browser: https://bbs.archlinux.org/viewtopic.php?id=117157)
* Icecat (GNU version of Firefox)
* Iceweasel (Debian version of Firefox)
* Inox (https://bbs.archlinux.org/viewtopic.php?id=198763)
* Luakit
* Midori
* Opera, Opera-Beta, Opera-Developer, and Opera-Legacy
* Otter-browser
* Palemoon
* QupZilla
* Qutebrowser
* Rekonq
* Seamonkey
* Surf (http://surf.suckless.org/)
* Vivaldi-browser and Vivaldi-browser-snapshot

## Documentation
Consult the man page, or see the [Arch Wiki article](https://wiki.archlinux.org/index.php/Profile-sync-daemon) for this software's upstream source.

## Installation
To build from source, see the included INSTALL text document.

## logcheck
Using logcheck? Here are some ways to filter out log lines:
```regexp
^\w{3} [ :0-9]{11} [._[:alnum:]-]+ profile-sync-daemon\[[0-9]+]\]: .*(google-chrome|firefox) (re|un)sync successful
^\w{3} [ :0-9]{11} [._[:alnum:]-]+ profile-sync-daemon\[[0-9]+\]: psd startup check successful$
^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: Started Timer for profile-sync-daemon
^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: psd(-resync)?\.service: Consumed [0-9\.]+s CPU time\.$
^\w{3} [ :0-9]{11} [._[:alnum:]-]+ systemd\[[0-9]+\]: psd(-resync)\.timer: Succeeded\.$
```
