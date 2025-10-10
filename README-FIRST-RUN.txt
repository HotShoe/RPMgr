                                                                            FIRST run of RPMgr
                                                                            jem@mlsoft.org

RPMgr is built with the QT libraies. You will need to have the qt6pas library installed before running RPMgr

sudo dnf5 install qt6pas

The above line will install the required library.

When RPMgr is first run on your system, it will require your sudo password, and will then build it's database.  This build process will  take some time to complete. You will see a notice telling you what is happening, and that dialog will go away once the process is complete.  rpmgr is retreving a list of all packages available in your enabled dnf5 repos, along with their descriptions and other information.  The time needed to do this depends on your internet speed as well as your machines speed.  On my laptop,  (a Ryzen 7 w/16GB memory), this takes about 35 seconds to complete running in a virtualbox VM. Your mileage will vary.

Once the initial DB is created, rpmgr will maintain it as packages are added or removed. The groups listed in the left group box can also be removed or added as a group of packages, and this list is also maintained by rpmgr. Rpmgr checks for updates each time it is run. If any are available, you will see a notification, and the Updates button in the main dialog will be red instead of navy. Currently, it can install, remove, and re-install, any package.

Rpmgr does not include a daemon to check for updates from the system. Discover and others already do this. I think that is it for the first run stuff.  The rpmgr.pdf "should" be up to date for running the program day to day. Please report any bugs that you find, or any suggestions  for future versions.

If you set up a desktop launcher,  if you are running under Wayland (and most are now), call RPMgr with a commandline like this :

rpmgr -platform=xcb

This will cure the problem that wayland has of moving windows around on the screen by forcing it to use x11 screen calls. This only affects the action panel when installing, removing, or reinstalling packages. Once this is fixed in Wayland, that commandline switch will not be needed.

SOURCE CODE

Source is available to beta testers to look through, but be warned now that rpmgr is written entirely in Object Pascal, using the Lazarus/fpc compilers. If you have pascal experience, I welcome any help . Please request the source through Email at jem@mlsoft.org. Understand that I need to control the source code until the project is released into the wild, so do NOT pass the source around to anyone else during the beta testing phase. A github will be available after the release.

--- Jem
