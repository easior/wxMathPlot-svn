#!/bin/bash

NATIVE=FALSE
DEBUG=FALSE
PKGNAME=wxmathplot

function create_source_tgz {
    VERSION=`cat ./distrib/VERSION`
    echo "Building packet $PKGNAME Versione $VERSION"
    PKGBASE=$PKGNAME-$VERSION
    PKGDIR=$PKGNAME-$VERSION
	
    if [[ -e ./distrib/$PKGBASE.tar.gz ]] ; then
        echo "$PKGBASE already exists: to avoid confusion, please change version"
        exit 1 ;
    else
        mkdir ./distrib/$PKGDIR ;
        mkdir -p ./distrib/$PKGDIR/{debian,distrib,include/wx,lib,samples,samples/sample{1,2,3},src,www}
        # Copy all sources
        for SRC in `find . -name '*.h' -o -name '*.cpp' -o -name 'CMakeLists.txt' -o -name '*.in' | grep -v 'distrib'` ; do
            cp $SRC ./distrib/$PKGDIR/`dirname $SRC`/
        done
        # Copy other useful files
        for SRC2 in {clear_project,README,Doxyfile,Dox_footer.html,Changelog,packages.sh,wxmathplot.pc.in,samples/sample3/gridmap.png,lib/README,distrib/Base.spec,distrib/VERSION,debian/README.Debian,debian/compat,debian/copyright,debian/docs,debian/wxmathplot-dev.dirs,debian/wxmathplot1.dirs,debian/changelog,debian/control,debian/dirs,debian/rules,debian/wxmathplot-dev.install,debian/wxmathplot1.install} ; do
            cp $SRC2 ./distrib/$PKGDIR/`dirname $SRC2`/
        done
        # Finally create tar.gz of source package
        cd ./distrib
        tar czf $PKGBASE.tar.gz $PKGDIR
        rm -rf $PKGDIR
        cd ..
    fi
}

function create_rpm {
    RPMPATH=~/rpmbuild/
    VERSION=`cat ./distrib/VERSION`
    echo "Building RPM $PKGNAME Versione $VERSION"
    PKGBASE=$PKGNAME-$VERSION
    if ! [[ -e ./distrib/$PKGBASE.tar.gz ]] ; then
        create_source_tgz
    fi
# Create the right SPEC file
    cat ./distrib/Base.spec | sed s/"Version:"/"Version: $VERSION"/ > ./distrib/$PKGBASE.spec
    cp ./distrib/$PKGBASE.spec $RPMPATH/SPECS
    cp ./distrib/$PKGBASE.tar.gz $RPMPATH/SOURCES
}

function create_deb {
    VERSION=`cat ./distrib/VERSION`
    CMAKEDIR=""
    if [[ -d /usr/share/cmake ]] ; then
        CMAKEDIR=/usr/share/cmake ;
    fi
    if [[ -d /usr/share/cmake-2.4 ]] ; then
        CMAKEDIR=/usr/share/cmake-2.4 ;
    fi
    if [[ -d /usr/share/cmake-2.6 ]] ; then
        CMAKEDIR=/usr/share/cmake-2.6 ;
    fi
    if [[ -d /usr/share/cmake-2.8 ]] ; then
        CMAKEDIR=/usr/share/cmake-2.8 ;
    fi
    if [[ -z $CMAKEDIR ]] ; then
        echo "CMake modules path not found. Aborting."
        exit 0 ;
    fi

    TMPCL=distrib/deb_tmp_cl
    #unlink debian/control
    DEBVERSION=`cat /etc/debian_version`
    case $DEBVERSION in
    	"4.0")
    		echo "using Debian Etch!"
    		OSVER="etch1"
    		# cd debian && ln -s control-debian control && cd ..
    	;;
    	"5.0")
    		echo "using Debian Lenny!"
    		OSVER="lenny1"
    		# cd debian && ln -s control-ubuntu control && cd ..
    	;;
    	"sid")
    		echo "This is Debian sid!"
    		OSVER="sid1"
    		# cd debian && ln -s control-sid control && cd ..
    	;;
    	"kali-rolling")
    		echo "This is Kali Linux, not Debian!"
    		OSVER="kali1"
    		# cd debian && ln -s control-kali control && cd ..
    	;;
    esac
    COMPLETE_VERSION=$VERSION-$OSVER
    echo "$PKGNAME ($COMPLETE_VERSION) unstable; urgency=low" > $TMPCL
    echo >> $TMPCL
    echo "  * " >> $TMPCL
    echo >> $TMPCL 
    echo -n " -- Davide Rondini <davide.rondini@samplesw.com>  " >> $TMPCL
    # LC_TIME="en_US.UTF-8"
    date -R >> $TMPCL
    echo >> $TMPCL
    #nano -w $TMPCL
    cat debian/changelog >> $TMPCL
    mv $TMPCL debian/changelog
    debuild -us -uc
}


if [[ $# -eq 0 ]] ; then
    echo "usage: packages.sh [tgz][rpm][deb]"
    exit 0 ;
fi

for PARAM in $* ; do
    if [[ $PARAM = "tgz" ]] ; then
        ./clear_project
        create_source_tgz
        exit 0 ;
    fi
    if [[ $PARAM = "rpm" ]] ; then
        ./clear_project
        create_rpm
#echo "Not yet implemented"
        exit 0 ;
    fi
    if [[ $PARAM = "deb" ]] ; then
        ./clear_project
        create_deb
        exit 0 ;
    fi

done

exit 0
