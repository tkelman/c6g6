FROM tkelman/c6g6:latest

RUN yum update -y && \
    yum install -y which patch xz m4 cmake openssl-devel centos-release-scl && \
    yum install -y git19 python27 && \
    source /opt/rh/git19/enable && \
    source /opt/rh/python27/enable && \
    git clone https://github.com/JuliaLang/julia /tmp/julia && \
    cd /tmp/julia && \
    make -j `nproc` -C deps FORCE_ASSERTIONS=1 LLVM_ASSERTIONS=1 && \
    echo 'clean_requirements_on_remove=1' >> /etc/yum.conf && \
    yum erase -y which patch xz m4 cmake openssl-devel centos-release-scl git19 python27 && \
    yum clean all
