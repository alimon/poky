#
# This class is used by recipes installing mime types
#

DEPENDS += "${@bb.utils.contains('BPN', 'shared-mime-info', '', 'shared-mime-info', d)}"
PACKAGE_WRITE_DEPS += "shared-mime-info-native"
MIMEDIR = "${datadir}/mime"

mime_postinst() {
if [ "x$D" != "x" ]; then
	$INTERCEPT_DIR/postinst_intercept update_mime_database ${PKG} \
		mlprefix=${MLPREFIX} \
		mimedir=${MIMEDIR}
else
	echo "Updating MIME database... this may take a while."
	update-mime-database $D${MIMEDIR}
fi
}

mime_postrm() {
if [ "x$D" != "x" ]; then
	$INTERCEPT_DIR/postinst_intercept update_mime_database ${PKG} \
		mlprefix=${MLPREFIX} \
		mimedir=${MIMEDIR}
else
	echo "Updating MIME database... this may take a while."
	update-mime-database $D${MIMEDIR}
fi
}

python populate_packages_append () {
    packages = d.getVar('PACKAGES').split()
    pkgdest =  d.getVar('PKGDEST')
    mimedir = d.getVar('MIMEDIR')

    for pkg in packages:
        mime_packages_dir = '%s/%s%s/packages' % (pkgdest, pkg, mimedir)
        mimes_types_found = False
        if os.path.exists(mime_packages_dir):
            for f in os.listdir(mime_packages_dir):
                if f.endswith('.xml'):
                    mimes_types_found = True
                    break
        if mimes_types_found:
            bb.note("adding mime postinst and postrm scripts to %s" % pkg)
            postinst = d.getVar('pkg_postinst_%s' % pkg)
            if not postinst:
                postinst = '#!/bin/sh\n'
            postinst += d.getVar('mime_postinst')
            d.setVar('pkg_postinst_%s' % pkg, postinst)
            postrm = d.getVar('pkg_postrm_%s' % pkg)
            if not postrm:
                postrm = '#!/bin/sh\n'
            postrm += d.getVar('mime_postrm')
            d.setVar('pkg_postrm_%s' % pkg, postrm)
            if pkg != 'shared-mime-info-data':
                bb.note("adding shared-mime-info-data dependency to %s" % pkg)
                d.appendVar('RDEPENDS_' + pkg, " " + d.getVar('MLPREFIX')+"shared-mime-info-data")
}
