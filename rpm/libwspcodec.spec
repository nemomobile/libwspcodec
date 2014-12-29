Name: libwspcodec
Version: 2.2
Release: 0
Summary: WSP encoder and decoder library
Group: Development/Libraries
License: GPLv2
URL: https://github.com/nemomobile/libwspcodec
Source: %{name}-%{version}.tar.bz2
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
make KEEP_SYMBOLS=1 release pkgconfig

%install
rm -rf %{buildroot}
make install-dev DESTDIR=%{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%{_libdir}/%{name}*.so.*

%files devel
%defattr(-,root,root,-)
%{_libdir}/%{name}-2.2.so
%{_libdir}/pkgconfig/libwspcodec.pc
%{_includedir}/libwspcodec/wspcodec/wsputil.h
%{_includedir}/libwspcodec/wspcodec/wspcodec.h
