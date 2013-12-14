Name: libwspcodec
Version: 1.0.0
Release: 1
Summary: WSP encoder and decoder library
Group: Development/Libraries
License: LGPL
URL: http://github.com/nemomobile
Source: %{name}-%{version}.tar.bz2
Requires: glib2 >= 2.0
BuildRequires: glib2-devel >= 2.0
Requires(post): /sbin/ldconfig
Requires(postun): /sbin/ldconfig

%description
Provides utilities to encode and decode WSP PDUs.

%package devel
Summary: Development library for %{name}
Requires: %{name} = %{version}
Requires: pkgconfig

%description devel
This package contains the development library for %{name}.

%prep
%setup -q

%build
make release pkgconfig

%install
rm -rf %{buildroot}
make install-dev DESTDIR=%{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_libdir}/%{name}.so*

%files devel
%defattr(-,root,root,-)
%{_libdir}/%{name}.so*
%{_libdir}/pkgconfig/libwspcodec.pc
%{_includedir}/libwspcodec/wspcodec/wsputil.h
%{_includedir}/libwspcodec/wspcodec/wspcodec.h
