FROM tkelman/c6g6:juliadeps

RUN yum update -y && \
    yum install -y which patch xz m4 cmake openssl-devel centos-release-scl && \
    yum install -y git19 python27 && \
    source /opt/rh/git19/enable && \
    source /opt/rh/python27/enable && \
    cd /tmp/julia && \
    git pull && \
    make -j `nproc` testall FORCE_ASSERTIONS=1 LLVM_ASSERTIONS=1 && \
    yum clean all
