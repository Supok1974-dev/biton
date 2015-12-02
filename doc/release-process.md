Release Process
====================

* * *

###update (commit) version in sources


	biton-qt.pro
	contrib/verifysfbinaries/verify.sh
	doc/README*
	share/setup.nsi
	src/clientversion.h (change CLIENT_VERSION_IS_RELEASE to true)

###tag version in git

	git tag -s v0.8.7

###write release notes. git shortlog helps a lot, for example:

	git shortlog --no-merges v0.7.2..v0.8.0

* * *

##perform gitian builds

 From a directory containing the biton source, gitian-builder and gitian.sigs
  
	export SIGNER=(your gitian key, ie bluematt, sipa, etc)
	export VERSION=0.8.7
	cd ./gitian-builder

 Fetch and build inputs: (first time, or when dependency versions change)

	mkdir -p inputs; cd inputs/
	wget 'http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.9.20140401.tar.gz' -O miniupnpc-1.9.20140401.tar.gz'
	wget 'https://www.openssl.org/source/openssl-1.0.1i.tar.gz'
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	wget 'http://zlib.net/zlib-1.2.8.tar.gz'
	wget 'ftp://ftp.simplesystems.org/pub/libpng/png/src/history/libpng16/libpng-1.6.8.tar.gz'
	wget 'http://fukuchi.org/works/qrencode/qrencode-3.4.3.tar.bz2'
	wget 'http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2'
	wget 'http://download.qt-project.org/official_releases/qt/4.8/4.8.5/qt-everywhere-opensource-src-4.8.5.tar.gz'
	cd ..
	./bin/gbuild ../biton/contrib/gitian-descriptors/boost-win32.yml
	mv build/out/boost-*.zip inputs/
	./bin/gbuild ../biton/contrib/gitian-descriptors/deps-win32.yml
	mv build/out/biton*.zip inputs/
	./bin/gbuild ../biton/contrib/gitian-descriptors/qt-win32.yml
	mv build/out/qt*.zip inputs/

 Build bitond and biton-qt on Linux32, Linux64, and Win32:
  
	./bin/gbuild --commit biton=v${VERSION} ../biton/contrib/gitian-descriptors/gitian.yml
	./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../biton/contrib/gitian-descriptors/gitian.yml
	pushd build/out
	zip -r biton-${VERSION}-linux.zip *
	mv biton-${VERSION}-linux.zip ../../
	popd
	./bin/gbuild --commit biton=v${VERSION} ../biton/contrib/gitian-descriptors/gitian-win32.yml
	./bin/gsign --signer $SIGNER --release ${VERSION}-win32 --destination ../gitian.sigs/ ../biton/contrib/gitian-descriptors/gitian-win32.yml
	pushd build/out
	zip -r biton-${VERSION}-win32.zip *
	mv biton-${VERSION}-win32.zip ../../
	popd

  Build output expected:

  1. linux 32-bit and 64-bit binaries + source (biton-${VERSION}-linux-gitian.zip)
  2. windows 32-bit binary, installer + source (biton-${VERSION}-win32-gitian.zip)
  3. Gitian signatures (in gitian.sigs/${VERSION}[-win32]/(your gitian key)/

repackage gitian builds for release as stand-alone zip/tar/installer exe

**Linux .tar.gz:**

	unzip biton-${VERSION}-linux-gitian.zip -d biton-${VERSION}-linux
	tar czvf biton-${VERSION}-linux.tar.gz biton-${VERSION}-linux
	rm -rf biton-${VERSION}-linux

**Windows .zip and setup.exe:**

	unzip biton-${VERSION}-win32-gitian.zip -d biton-${VERSION}-win32
	mv biton-${VERSION}-win32/biton-*-setup.exe .
	zip -r biton-${VERSION}-win32.zip biton-${VERSION}-win32
	rm -rf biton-${VERSION}-win32

**Perform Mac build:**

  OSX binaries are created on a dedicated 32-bit, OSX 10.6.8 machine.
  Biton 0.8.x is built with MacPorts.  0.9.x will be Homebrew only.

	qmake RELEASE=1 USE_UPNP=1 USE_QRCODE=1
	make
	export QTDIR=/opt/local/share/qt4  # needed to find translations/qt_*.qm files
	T=$(contrib/qt_translations.py $QTDIR/translations src/qt/locale)
	python2.7 share/qt/clean_mac_info_plist.py
	python2.7 contrib/macdeploy/macdeployqtplus Biton-Qt.app -add-qt-tr $T -dmg -fancy contrib/macdeploy/fancy.plist

 Build output expected: Biton-Qt.dmg

###Next steps:

* Code-sign Windows -setup.exe (in a Windows virtual machine) and
  OSX Biton-Qt.app (Note: only Gavin has the code-signing keys currently)

* update biton.pw version
  make sure all OS download links go to the right versions

* update forum version

* update wiki download links

Commit your signature to gitian.sigs:

	pushd gitian.sigs
	git add ${VERSION}/${SIGNER}
	git add ${VERSION}-win32/${SIGNER}
	git commit -a
	git push  # Assuming you can push to the gitian.sigs tree
	popd

