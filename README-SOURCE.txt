                                                                         README-SOURCE for RPMgr
                                                                                  jem@mlsoft.org

If you are not using the standard installation of Lazarus from the official RPM, or the RPM packages from the
Fedora repositories, you must edit the file:

build-rpmgr

and insert the path to your Lazarus directory before the lazbuild command. Like this :

/path/to/Lazarus/lazbuild --build-mode=release rpmgr.lpr

You can also set the Lazarus directory path into your $PATH statement, or configure a /home/username/bin directory in your .bashrc file. You can then create a link to the lazbuild command in that directory.

The following external packages are used in rpmgr :
BGRAcontrols
ZeosDBO

These can be installed from the online package manager in Lazarus.

RPMgr also uses the QT5 widget set. You will need to install the qt5pas libraries

sudo dnf5 install qt5pas-devel

The line above should install all required packages. Then the rpmgr program should compile using the build-rpmgr script.

jem@mlsoft.org
