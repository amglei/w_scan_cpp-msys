# w_scan_cpp (SAT>IP-only) – MSYS2-Build

Baut `w_scan_cpp` unter Windows mit MSYS2 (msys-Toolchain, kein MinGW):
SAT>IP-Tuning via vendored VDR + vdr-plugin-satip, Linux-DVB-Header als Shim.

## Herkunft, Dank, Lizenz

Dieses Repo ist ein Fork von
[wirbel-at-vdr-portal/w_scan_cpp](https://github.com/wirbel-at-vdr-portal/w_scan_cpp)
und enthält ausschließlich Ergänzungen für den MSYS2-Build (Patches, Skripte, CI);
die Upstream-Quellen liegen unverändert in `w-scan-cpp-20260515+dfsg/`, Änderungen
dazu als `patches/101-*` … `patches/112-*`.

- Original-Autor: **Winfried Koehler („wirbel“)**, Projektseite:
  <https://www.gen2vdr.de/wirbel/w_scan_cpp/index2.html>
- Mitwirkende siehe Upstream-Datei `CONTRIBUTORS`.
- `w_scan_cpp` basiert auf [VDR](https://www.tvdr.de) von Klaus Schmidinger,
  [vdr-plugin-satip](https://github.com/rofafor/vdr-plugin-satip) von Rolf Ahrenberg
  sowie dem VDR-Plugin wirbelscan – Dank an alle Beteiligten.
- Lizenz: **GNU General Public License v2** (siehe `COPYING`, Upstream-Original).
  Alle Dateien dieses Forks, die Upstream-Code enthalten oder davon abgeleitet sind,
  stehen ebenfalls unter GPL-2.0.

## Schnellstart

```cmd
build.cmd
```

Nutzt MSYS unter `C:\msys64`; abweichender Pfad via Env `MSYS_ROOT`
oder `build.cmd --msys-root <Pfad>`.

## Pipeline (`tools/build.sh`)

| # | Stufe | Skript |
|---|-------|--------|
| 1 | MSYS-Pakete installieren (`pacman`) | `tools/01-install.sh` |
| 2 | Patches 101–112 auf pristine Tree | `tools/00-apply-patches.sh` |
| 3 | Vendor-/Hygiene-Checks | `tools/02-prepare.sh` |
| 4 | librepfunc (statisch) | `tools/03-librepfunc.sh` |
| 5 | Build + `--help`-Gate | `tools/04-build.sh` |
| 6 | Paket `dist/w_scan_cpp-msys-x86_64/` | `tools/05-package.sh` |
| 7 | Smoke-Test: dist-`--help` + DLL-Herkunft (ohne Netz) | inline |

Option `--skip-install`, wenn MSYS schon eingerichtet ist.

## Verify (braucht SAT>IP-Server im Netz)

`bash tools/verify-femon.sh` stimmt einen Transponder ab (per `timeout`
begrenzt) und verlangt `lock 1`. Braucht `SATIP_SERVER="IP|MODEL|DESC"`
(Env oder `--satip-server`); optional `--verify-channel`, `--exe`, `--timeout`.

## CI

`.github/workflows/msys-build.yml` richtet MSYS2 ein und ruft dieselbe
Pipeline auf (`tools/build.sh --skip-install`), inkl. `--help`-Gate und
Artifact-Upload aus `dist/`. Tag pushen (z. B. `v2026.09.08`) erzeugt
automatisch ein GitHub-Release mit `w_scan_cpp-msys-x86_64.zip`
(Exe + DLLs + Lizenzen).

## Werkzeuge (nicht Teil der Pipeline)

- `tools/verify-femon.sh` – Lock-Test eines Transponders (s. Verify).
- `tools/rtsp-tune-test.py` – reiner RTSP-Tune-Test eines Transponders.
- `tools/ssdp-*.py` – SSDP-/M-SEARCH-Diagnose.
- `tools/06-patches.sh` – Patches aus Diffs regenerieren (Dev).
- `tools/firewall-rules.ps1` – Windows-Firewallregeln (als Admin).
