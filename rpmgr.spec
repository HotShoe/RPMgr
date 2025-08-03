Name:           rpmgr
Version:        0.9.6
Release:        1%{?dist}
Summary:        Graphical RPM package manager for fedora 41+

License:        Apache 2.0
URL:            https://www.mlsoft.org/rpmgr.html
Source0:        file:///mnt/Data/rpmgr/rpmgr-src-%{version}.%{arch}

BuildRequires:  lazarus, lazbuild
Requires:       libQt6Pas.so.1, libX11.so.6, libc.so.6

%description
RPMgr is a graphical front end for the Fedora dnf5 and rpm package management system. It allows administrators to carry out the most often used tasks offered by both of those packages, including : Installing, Removing, Re-installing of packages and groups. It also handles package updates, distribution upgrades, and managing package repositories.

%prep
%autosetup


%build
lazbuild --build-mode=x86_64-release rpmgr.lpr


%install
%make_install


%files
%license LICENCE
%doc rpmgr.pdf, rpmgr.8.gz



%changelog
* Sun Jul 29 2025 Jem Miller
- 
