FROM centos:6

# glibc-devel is manually installed so it doesn't
# get removed when gcc-c++ does
RUN GCCVER=6.1.0 && \
    yum install -y tar bzip2 gcc-c++ glibc-devel && \
    mkdir /tmp/c6g6 && \
    cd /tmp/c6g6 && \
    curl http://mirrors.concertpass.com/gcc/releases/gcc-$GCCVER/gcc-$GCCVER.tar.bz2 | \
    tar -xjf - && \
    cd /tmp/c6g6/gcc-$GCCVER && \
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
    yum clean && \
    rm -rf /tmp/c6g6


# build julia, to test if things work
RUN yum install -y which patch xz centos-release-scl && \
    yum install -y git19 python27 devtoolset-4-binutils && \
    ln -s /opt/rh/git19/root/usr/bin/git /usr/local/bin/git && \
    ln -s /opt/rh/python27/root/usr/bin/python /usr/local/bin/python && \
    ln -s /opt/rh/devtoolset-4/root/usr/bin/as /usr/local/bin/as && \
    git clone https://github.com/JuliaLang/julia /tmp/julia && \
    cd /tmp/julia && \
    make -j `nproc` testall
