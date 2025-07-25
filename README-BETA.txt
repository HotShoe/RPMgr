                                                                       Beta test program for RPMgr

!!!!!!!!!!! This package REQUIRES Fedora 41 or higher !!!!!!!!!!!!!!

During the beta test period, this software is distributed to volunteer testers as a .zip package. This is for convenience and ease of use.  

You must use the beta package as a user that has wheel access (the ability to run sudo). Otherwise the security manager of RPMgr will simply terminate the program after 3 login attempts, or if the Cancel button is clicked on the login dialog.

 This can be run in a VM, chroot, or other sandbox environment. Even though RPMgr appears to run well,  I fully expect the unexpected error, and this package DOES have the ability to harm your system.  For that reason I suggest a sandbox of some kind.

RPMgr doesn't particularly care where it is run from. I suggest a dir named rpmgr in your $HOME directory, but it can be run from most anywhere during the beta phase. Later the binary will be packaged into an RPM file and nstalled to the /usr/bin directory, but your $HOME directory will be used for the config file and logs.

Each user gets their own config file. That file is kept in ~/.config/rpmgr/rpmgr.cfg. the program will create that directory as needed, and will create the config file on first run. From that point RPMgr uses the dnf5 and rpm interfaces to do all of the heavy work.

You will need to install the qt5pas library using the line below

sudo dnf5 install qt5pas

There are no library files for rpmgr. There is a man page and  docs (sort of), and probably will be a help system of some kind. For now I am concerned with getting it ro run reliably and error free on as many systems as possible during this beta test period.

As always, I can be reached at jem@mlsoft.org. If you need direct contact, I am happy to provide my phone number to beta testers.

PLEASE READ THE README-FIRST-RUN.txt file next.