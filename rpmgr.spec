%global debug_package %{nil}

Name:           rpmgr
Version:        0.9.8.6
Release:        1%{?dist}
Summary:        Graphical desktop interface to the Fedora 41+ DNF5 and RPM package managers

License:        Apache2.0 and MLsoft Open Source License Agreement
URL:            http://www.mlsoft.org/rpmgr.html
Source0:        http://www.mlsoft.org/rpmgr-0.9.8.6.tar.gz
Source1:        BGRABitmap.zip
Source2:        BGRAControls.zip
Source3:        ZeosDBO.zip
Source4:        package-links

BuildRequires:  desktop-file-utils
BuildRequires:  qt6pas-devel
BuildRequires:  lazarus
BuildRequires:  lazarus-lcl-qt6
BuildRequires:  libXtst-devel

Requires:  sudo
Requires:  repo
Requires:  qt6pas
Requires:  bash

%description
The RPMgr software (RPM Manager) is a graphical desktop interface to the DNF5 and RPM programs used and distributed in the Fedora Linux operating system. RPMgr is designed to be easy to use and to understand by any level of Linux user. It allows you to install, remove, and reinstall packages into your Linux system. It also allows you to install entire groups of packages (called groups), and to remove installed groups. It will check for updates each time it is run, and allow you to install those update in two different ways. It can also do a complete distribution upgrade to the next version of fedora, when one becomes available."


%prep
%autosetup
cp %{SOURCE4} ./
unzip  %{SOURCE1} -d ./
unzip  %{SOURCE2} -d ./
unzip  %{SOURCE3} -d ./

%build
./package-links
./build-rpmgr

%install
install -D -m755    rpmgr              %{buildroot}%{_datadir}/rpmgr/rpmgr
install -D -m755    lhelp              %{buildroot}%{_bindir}/lhelp
install -D -m644    rpmgr.desktop      %{buildroot}%{_datadir}/applications/rpmgr.desktop
install -D -m644    rpmgr.png          %{buildroot}%{_datadir}/pixmaps/rpmgr.png
install -D -m644    rpmgr.8.gz         %{buildroot}%{_datadir}/man/man8/rpmgr.8.gz
install -D -m774    rpmgr.db           %{buildroot}%{_datadir}/rpmgr/rpmgr.db
install -D -m644    rpmgr.chm          %{buildroot}%{_datadir}/rpmgr/rpmgr.chm
install -D -m644    locale/*           %{buildroot}%{_datadir}/rpmgr/locale

%post
chown root:wheel %{_datadir}/rpmgr
chown root:wheel %{_datadir}/rpmgr/rpmgr.db
chmod 774  %{_datadir}/rpmgr
chmod 774  %{_datadir}/rpmgr/rpmgr.db
chmod 644  %{_datadir}/rpmgr/rpmgr.chm
chmod 775  %{_datadir}/rpmgr/locale
chmod 644  %{_datadir}/rpmgr/locale/*
ln -s %{_bindir}/rpmgr %{_datadir}/rpmgr/rpmgr

%check
desktop-file-validate %{buildroot}/%{_datadir}/applications/rpmgr.desktop ||:

%files
%license LICENSE mlsoft2.1.txt
%doc README-BETA.txt README-FIRST-RUN.txt README-SOURCE.txt rpmgr.pdf
%locale locale/*

%{_bindir}/rpmgr
%{_bindir}/lhelp
%{_datadir}/applications/rpmgr.desktop
%{_datadir}/pixmaps/rpmgr.png
%{_datadir}/man/man8/rpmgr.8.gz
%{_datadir}/rpmgr/rpmgr
%{_datadir}/rpmgr/rpmgr.db
%{_datadir}/rpmgr/rpmgr.chm

%changelog
* Thu Aug 14 2025 Jem Miller <jem@mlsoft.org> - 0.9.8.6-0
- Update to 0.9.8.6
