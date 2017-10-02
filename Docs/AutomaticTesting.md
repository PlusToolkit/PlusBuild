How to set up the automatic nightly tests
-----------------------------------------

The automatic nightly build is used for regular automatic testing of the Plus library on multiple platforms to make sure there are no regressions introduced by code changes.

- Build Plus. It is recommended to create a separate directory for the automatic nightly build, where files are not modified after downloading them from the repository.
- Add a scheduled task
  - Windows XP: Create a new scheduled task at Control Panel / Scheduled Tasks / Add Scheduled
  - Windows 7: Task scheduler can be found at Start Menu / All Programs / Accessories / System Tools / Task Scheduler.
- Add the PlusNightly-build\PlusBuildAndTest.bat batch file with -N parameter and set the start directory to PlusNightly-build.
- Schedule the task to run it daily during the night (e.g., at 1:00AM). On Windows 7, "Start in (optional):" setting (in Actions properties) can be the PlusNightly-build folder.
- Enable firewall exception so that the scheduled task can communicate with CDash
  - Windows XP: Click Start, Control Panel, double-click Windows Firewall, select the Exceptions tab, and then select the File and Printer Sharing firewall exception. Then click the Ok button in the Windows Firewall dialog box.
  - Windows 7: Click Start, Control Panel, Security, Allow a program through Windows Firewall, and then select the Remote Scheduled Tasks Management check box. Then click the Ok button in the Windows Firewall Settings dialog box.
- Check the results at our CDash page on the next day to make sure that the test was executed during the night and the results were submitted to the dashboard
