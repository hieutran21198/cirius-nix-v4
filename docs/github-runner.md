# GitHub runner storage

The `cirius-go-platform` runner on `mht-home-pc` keeps its disposable work directory
at `/var/cache/github-runner/cirius-go-platform/work`. The root filesystem is
Btrfs on NVMe. The old `/mnt/main-data/Github-Runners` location is NTFS on a
rotational disk. Checkouts, `node_modules`, and the runner's `HOME` caches belong
on the faster filesystem; no CPU, memory, test-timeout, or concurrency changes
are needed for this move.

Systemd creates the work directory through `CacheDirectory` with the service's
existing user and group. The NixOS runner module uses it for both `HOME` and
`WorkingDirectory` and **deletes its contents on every service start**. Do not
put persistent data there. The existing tool and Terraform provider caches are
separate siblings and keep their current paths. Runner registration state stays
in `/var/lib/github-runner/cirius-go-platform`, outside the disposable work tree.

## Owner rollout

This repository change does not migrate files or activate the host.

1. Wait for the runner to finish its current job, then stop the runner service
   so it cannot accept another job during the maintenance window.
2. Changing `workDir` makes the pinned NixOS module re-register the runner. It
   clears the old local registration state, but does not remove the old GitHub
   registration. With `replace = false`, remove the old offline registration in
   GitHub as part of the maintenance window before starting the new config.
   Confirm the configured token is still suitable for registration; a one-hour
   registration token may have expired. Do not change or print the token here.
3. Apply the reviewed configuration using the normal host deployment process.
   Verify the runner is online with the same name and labels. The first job
   starts with a fresh checkout and HOME caches. Old files on NTFS are untouched;
   do not copy credentials or the old workspace into the new directory.
4. Check `WorkingDirectory`, `CacheDirectory`, and `HOME` for
   `github-runner-cirius-go-platform.service`, then verify an ordinary job logs a
   checkout below the new work directory. Check SSD free space as caches grow.
5. Compare repeated equivalent workload timings after the first warm-up job.
   The move has not been benchmarked in live CI and does not prove the cause of
   [the 12-second typed ESLint startup](https://github.com/hieutran21198/cirius-go-platform/actions/runs/42368037444/job/128390627405).
   [Platform PR #195](https://github.com/hieutran21198/cirius-go-platform/pull/195)
   handles that test's setup separately.

Rolling back the work-directory setting also triggers re-registration and clears
the selected work directory on start. Use the same idle-runner maintenance
procedure; do not rely on the old checkout as a backup.
