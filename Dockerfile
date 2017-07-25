FROM tkelman/c6g6:c5g7

# llvm xz tarballs don't work with very old gtar
# gl_cv_func_mknod_works=yes is because I'm too lazy to run this as non-root
# gl_cv_func_getcwd_path_max=yes is to avoid too-long confdir3/confdir3/...
# CFLAGS=-fgnu89-inline is to avoid 'multiple definition of realpath' etc linker errors
RUN TARVER=1.29 && \
    mkdir /tmp/gtar && \
    cd /tmp/gtar && \
    wget http://ftp.gnu.org/gnu/tar/tar-$TARVER.tar.bz2 && \
    tar -xjf tar-$TARVER.tar.bz2 && \
    cd /tmp/gtar/tar-$TARVER && \
    ./configure gl_cv_func_mknod_works=yes \
        gl_cv_func_getcwd_path_max=yes CFLAGS=-fgnu89-inline && \
    make -j8 && \
    make install && \
    yum erase -y tar && \
    yum clean all && \
    rm -rf /tmp/gtar

# llvm needs python 2.7 which isn't in any centos 5 repos
RUN PYVER=2.7.13 && \
    mkdir /tmp/py27 && \
    cd /tmp/py27 && \
    wget https://www.python.org/ftp/python/$PYVER/Python-$PYVER.tgz && \
    tar -xzf Python-$PYVER.tgz && \
    cd /tmp/py27/Python-$PYVER && \
    ./configure && \
    make -j8 && \
    make install && \
    rm -rf /tmp/py27

# use cmake 3.6.1 instead of 3.7.1 because recent binaries don't run on centos 5
RUN yum install -y which patch xz m4 wget epel-release && \
    yum install -y git && \
    git clone https://github.com/JuliaLang/julia /tmp/julia && \
    cd /tmp/julia && \
    sed -e 's/MINOR=7/MINOR=6/' -e 's/| sha/#/g' \
        contrib/download_cmake.sh > contrib/download_cmake361.sh && \
    sh contrib/download_cmake361.sh && \
    echo 'override FORCE_ASSERTIONS = 1' >> Make.user && \
    echo 'override LLVM_ASSERTIONS = 1' >> Make.user && \
    make -j8 -C deps && \
    yum clean all

#    yum erase -y which patch xz m4 wget epel-release git && \

WORKDIR /tmp/julia
