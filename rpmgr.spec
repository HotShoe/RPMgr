%global debug_package %{nil}
%global sudoers_file rpmgr.sudoers

Name:           rpmgr
Version:        1.0.0
Release:        0%{?dist}
Summary:        Graphical desktop interface to the Fedora 41+ DNF5 and RPM package managers

License:        Apache2.0 and MLsoft2.1
URL:            http://www.mlsoft.org/rpmgr.html
Source0:        http://www.mlsoft.org/rpmgr-1.0.0.tar.gz
Source1:        BGRABitmap.zip
Source2:        BGRAControls.zip
Source3:        ZeosDBO.zip
Source4:        package-links

BuildRequires:  desktop-file-utils
BuildRequires:  qt6pas-devel
BuildRequires:  lazarus
BuildRequires:  lazarus-lcl-qt6
BuildRequires:  libXtst-devel
BuildRequires: gettext

Requires:  sudo
Requires:  repo
Requires:  qt6pas
Requires:  bash

%description
The RPMgr software (RPM Manager) is a graphical desktop interface to the DNF5 and RPM programs used and distributed in the Fedora Linux operating system. RPMgr is designed to be easy to use and to understand by any level of Linux user. It allows you to install, remove, and reinstall packages into your Linux system. It also allows you to install entire groups of packages (called groups), and to remove installed groups. It will check for updates each time it is run, and allow you to install those update in two different ways. It can also do a complete distribution upgrade to the next version of fedora, when one becomes available.


%prep
%autosetup
cp %{SOURCE4} ./
unzip  %{SOURCE1} -d ./
unzip  %{SOURCE2} -d ./
unzip  %{SOURCE3} -d ./

%build
./package-links
./build-rpmgr
mkdir -p locale/en/LC_MESSAGES
msgfmt -o locale/en/LC_MESSAGES/rpmgr.mo rpmgr.en.po

%install
install -D -m755    rpmgr              %{buildroot}%{_bindir}/rpmgr
install -D -m755    lhelp              %{buildroot}%{_bindir}/lhelp
install -D -m644    rpmgr.png          %{buildroot}%{_datadir}/pixmaps/rpmgr.png
install -D -m644    rpmgr.8.gz         %{buildroot}%{_datadir}/man/man8/rpmgr.8.gz
install -D -m774 rpmgr.db %{buildroot}/var/lib/rpmgr/rpmgr.db
install -D -m644 rpmgr.chm %{buildroot}%{_datadir}/rpmgr/rpmgr.chm
install -m 755 -d %{buildroot}/etc/sudoers.d/
install -m 440 %{_sourcedir}/rpmgr.sudoers %{buildroot}/etc/sudoers.d/
install -D -m644 locale/en/LC_MESSAGES/rpmgr.mo %{buildroot}%{_datadir}/locale/en/LC_MESSAGES/rpmgr.mo
desktop-file-install --dir=%{buildroot}%{_datadir}/applications rpmgr.desktop


%post
# rpmgr.db must be writable by wheel group for update operations via RPMgr interface
chown root:root %{_datadir}/rpmgr
chown root:wheel /var/lib/rpmgr
chmod 774 /var/lib/rpmgr/rpmgr.db
chmod 755  %{_datadir}/rpmgr
chmod 644  %{_datadir}/rpmgr/rpmgr.chm

%postun
# This script runs on package uninstallation. It removes the sudoers file.
if [ "$1" = "0" ]; then
    echo "Removing RPMgr sudoers configuration..."
    rm -f /etc/sudoers.d/rpmgr.sudoers
fi

%check
desktop-file-validate %{buildroot}/%{_datadir}/applications/rpmgr.desktop ||:

%files
%license LICENSE mlsoft2.1.txt
%doc  rpmgr.pdf

%config(noreplace) /etc/sudoers.d/%{sudoers_file}
%config(noreplace) /var/lib/rpmgr/rpmgr.db
%{_datadir}/rpmgr/rpmgr.chm
%{_bindir}/rpmgr
%{_bindir}/lhelp
%{_datadir}/applications/rpmgr.desktop
%{_datadir}/pixmaps/rpmgr.png
%{_datadir}/man/man8/rpmgr.8.gz
%{_datadir}/rpmgr/rpmgr
%{_datadir}/locale/en/LC_MESSAGES/rpmgr.mo

%changelog
* Thu Oct 17 2025 Jem Miller <jem@mlsoft.org> - 1.0.0-0
- Update to 1.0.0

* Thu Aug 14 2025 Jem Miller <jem@mlsoft.org> - 0.9.9.6-0
- Update to 0.9.8.6
