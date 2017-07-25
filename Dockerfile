FROM tkelman/c6g6:2.0.0

RUN yum update -y && \
    yum install -y which patch xz m4 centos-release-scl && \
    yum install -y git19 python27 && \
    source /opt/rh/git19/enable && \
    source /opt/rh/python27/enable && \
    git clone https://github.com/JuliaLang/julia /tmp/julia && \
    cd /tmp/julia && contrib/download_cmake.sh && \
    make -j `nproc` FORCE_ASSERTIONS=1 LLVM_ASSERTIONS=1 && \
#    yum erase -y which patch xz m4 centos-release-scl \
#        git19 python27 --setopt=clean_requirements_on_remove=1 && \
    yum clean all
