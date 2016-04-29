FROM centos:6

# glibc-devel is manually installed so it doesn't
# get removed when gcc-c++ does
# put new binutils in place so it gets built along with gcc
RUN GCCVER=6.1.0 && \
    BINUTILSVER=2.26 && \
    yum install -y tar bzip2 gcc-c++ glibc-devel && \
    mkdir /tmp/c6g6 && \
    cd /tmp/c6g6 && \
    curl http://mirrors.concertpass.com/gcc/releases/gcc-$GCCVER/gcc-$GCCVER.tar.bz2 | tar -xjf - && \
    curl http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILSVER.tar.bz2 | tar -xjf - && \
    cd /tmp/c6g6/gcc-$GCCVER && \
    for i in bfd binutils cpu elfcpp etc gas gold gprof ld opcodes texinfo; \
        do ln -s /tmp/c6g6/binutils-$BINUTILSVER/$i; done && \
    echo 'curl -O $1' > /usr/local/bin/wget && \
    chmod +x /usr/local/bin/wget && \
    contrib/download_prerequisites && \
    rm /usr/local/bin/wget && \
    mkdir /tmp/c6g6/build && \
    cd /tmp/c6g6/build && \
    ../gcc-$GCCVER/configure --disable-multilib --enable-languages=c,c++,fortran && \
    make -j `nproc` && \
    make install && \
    echo 'clean_requirements_on_remove=1' >> /etc/yum.conf && \
    yum erase -y gcc-c++ && \
    yum clean all && \
    rm -rf /tmp/c6g6 && \
    export LD_LIBRARY_PATH=/usr/local/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}


# build julia, to test if things work
RUN yum install -y which patch xz m4 cmake openssl-devel centos-release-scl && \
    yum install -y git19 python27 && \
    source /opt/rh/git19/enable && \
    source /opt/rh/python27/enable && \
    git clone https://github.com/JuliaLang/julia /tmp/julia && \
    cd /tmp/julia && \
    make -j `nproc` testall
