#!/bin/bash
VERSION="1.0.2"
PACKAGE_NAME="ongaku"
ARCHITECTURE="amd64"

echo "Packaging ${PACKAGE_NAME} v${VERSION}..."

rm -rf build
rm -rf debian_package/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}
rm -f debian_package/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb

echo "Building..."
meson setup build
ninja -C build

echo "Creating package structure..."
PACKAGE_DIR="debian_package/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}"
mkdir -p ${PACKAGE_DIR}/DEBIAN
mkdir -p ${PACKAGE_DIR}/usr/bin
mkdir -p ${PACKAGE_DIR}/usr/share/applications
mkdir -p ${PACKAGE_DIR}/usr/share/icons/hicolor/scalable/apps
mkdir -p ${PACKAGE_DIR}/usr/share/icons/hicolor/48x48/apps
mkdir -p ${PACKAGE_DIR}/usr/share/icons/hicolor/64x64/apps

cp build/ongaku ${PACKAGE_DIR}/usr/bin/
cp media/logo.svg ${PACKAGE_DIR}/usr/share/icons/hicolor/scalable/apps/ongaku.svg

if command -v inkscape >/dev/null 2>&1; then
    inkscape --export-type=png --export-width=48 --export-height=48 \
        media/logo.svg -o ${PACKAGE_DIR}/usr/share/icons/hicolor/48x48/apps/ongaku.png
    inkscape --export-type=png --export-width=64 --export-height=64 \
        media/logo.svg -o ${PACKAGE_DIR}/usr/share/icons/hicolor/64x64/apps/ongaku.png
fi

cat > ${PACKAGE_DIR}/usr/share/applications/ongaku.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Ongaku
Comment=Download Music Freely
Exec=ongaku
Icon=ongaku
Terminal=false
Categories=AudioVideo;Audio;
Keywords=youtube;download;music;mp3;playlist;
EOF

cat > ${PACKAGE_DIR}/DEBIAN/control << EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}
Section: multimedia
Priority: optional
Architecture: ${ARCHITECTURE}
Depends: libgtk-4-1, libadwaita-1-0, yt-dlp
Maintainer: Arell <arell@example.com>
Description: Download Music Freely
 Ongaku is a modern GTK4/Libadwaita application for downloading
 audio from YouTube videos and playlists as MP3 files.
 .
 Features:
  - Download individual YouTube videos as MP3
  - Download entire YouTube playlists
  - Modern GTK4/Libadwaita interface
  - Progress tracking
  - History of downloaded files
EOF

cat > ${PACKAGE_DIR}/DEBIAN/postinst << 'EOF'
#!/bin/bash
set -e

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor
fi

exit 0
EOF

cat > ${PACKAGE_DIR}/DEBIAN/prerm << 'EOF'
#!/bin/bash
set -e

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q
fi

exit 0
EOF

chmod 755 ${PACKAGE_DIR}/DEBIAN/postinst
chmod 755 ${PACKAGE_DIR}/DEBIAN/prerm

INSTALLED_SIZE=$(du -sk ${PACKAGE_DIR}/usr | cut -f1)
echo "Installed-Size: ${INSTALLED_SIZE}" >> ${PACKAGE_DIR}/DEBIAN/control

echo "Building .deb package..."
dpkg-deb --build ${PACKAGE_DIR}

echo "Package created: debian_package/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
echo ""
echo "To install:"
echo "sudo dpkg -i debian_package/${PACKAGE_NAME}_${VERSION}_${ARCHITECTURE}.deb"
echo ""
echo "To uninstall previous version:"
echo "sudo apt remove ${PACKAGE_NAME}"
