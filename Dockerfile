FROM centos:6

# glibc-devel is manually installed so it doesn't get removed when gcc-c++ does
# put new binutils in place so it gets built along with gcc
# centos 6 docker image comes with curl but not wget by default
RUN GCCVER=6.1.0 && \
    BINUTILSVER=2.27 && \
    yum update -y && \
    yum install -y tar bzip2 gcc-c++ glibc-devel && \
    mkdir /tmp/c6g6 && \
    cd /tmp/c6g6 && \
    curl http://mirrors.concertpass.com/gcc/releases/gcc-$GCCVER/gcc-$GCCVER.tar.bz2 | tar -xjf - && \
    curl http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILSVER.tar.bz2 | tar -xjf - && \
    cd /tmp/c6g6/gcc-$GCCVER && \
    for i in bfd binutils cpu elfcpp etc gas gold gprof ld opcodes texinfo; \
        do ln -s /tmp/c6g6/binutils-$BINUTILSVER/$i; done && \
    sed -i 's/wget/curl -O/g' contrib/download_prerequisites && \
    contrib/download_prerequisites && \
    mkdir /tmp/c6g6/build && \
    cd /tmp/c6g6/build && \
    ../gcc-$GCCVER/configure --disable-multilib --enable-languages=c,c++,fortran && \
    make -j `nproc` && \
    make install && \
    yum erase -y gcc-c++ --setopt=clean_requirements_on_remove=1 && \
    yum clean all && \
    rm -rf /tmp/c6g6

ENV LD_LIBRARY_PATH /usr/local/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
