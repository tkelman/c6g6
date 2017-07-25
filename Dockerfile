FROM centos:5.11

# put new binutils in place so it gets built along with gcc
# multilib_policy=best is to avoid 32 bit versions of curl etc
RUN GCCVER=7.1.0 && \
    BINUTILSVER=2.28 && \
    sed -i 's|enabled=1|enabled=0|' /etc/yum/pluginconf.d/fastestmirror.conf && \
    sed -i 's|mirrorlist=|#mirrorlist=|' /etc/yum.repos.d/*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org/centos/$releasever|baseurl=http://vault.centos.org/5.11|' /etc/yum.repos.d/*.repo && \
    echo 'multilib_policy=best' >> /etc/yum.conf && \
    yum update -y && \
    yum install -y curl bzip2 make gcc-c++ && \
    mkdir /tmp/c5g7 && \
    cd /tmp/c5g7 && \
    curl http://mirrors.concertpass.com/gcc/releases/gcc-$GCCVER/gcc-$GCCVER.tar.bz2 | tar -xjf - && \
    curl http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILSVER.tar.bz2 | tar -xjf - && \
    cd /tmp/c5g7/gcc-$GCCVER && \
    for i in bfd binutils cpu elfcpp etc gas gold gprof ld opcodes texinfo; \
        do ln -s /tmp/c5g7/binutils-$BINUTILSVER/$i; done && \
    sed -i 's/--no-verbose//' contrib/download_prerequisites && \
    contrib/download_prerequisites && \
    mkdir /tmp/c5g7/build && \
    cd /tmp/c5g7/build && \
    ../gcc-$GCCVER/configure --disable-multilib --enable-languages=c,c++,fortran && \
    make -j8 && \
    make install && \
    yum erase -y gcc-c++ cpp gcc libgomp libstdc++-devel && \
    yum clean all && \
    rm -rf /tmp/c5g7

# does not work with old yum?
#    echo 'clean_requirements_on_remove=1' >> /etc/yum.conf && \

ENV LD_LIBRARY_PATH /usr/local/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
