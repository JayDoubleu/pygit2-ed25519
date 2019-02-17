FROM centos
# Install dependecies
RUN yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install python-virtualenv libffi-devel libcurl-devel cmake autoreconf git curl http-parser-devel libgpg-error-devel zlib-devel perl-core

# Compile OpenSSL 1.1.1 (ed25519 support)
RUN curl -o /tmp/openssl.tar.gz https://www.openssl.org/source/openssl-1.1.1.tar.gz
RUN tar -xvf /tmp/openssl.tar.gz -C /tmp/
WORKDIR "/tmp/openssl-1.1.1"
RUN ./config prefix=/usr/local/ssl openssldir=/usr/local/ssl shared zlib
RUN make && make install
RUN /bin/cp -rf /usr/local/lib64/* /lib64/ && ldconfig

# Compile libssh2 (ed25519 support)
RUN git clone https://github.com/libssh2/libssh2.git /tmp/libssh2 && cd /tmp/libssh2 && git reset --hard cf13c9925c42e6e9eeaa6525f43aedc9ed2df9ec
RUN mkdir /tmp/libssh2/build
RUN ls
WORKDIR "/tmp/libssh2/build"
RUN cmake .. && cmake -DBUILD_SHARED_LIBS=ON --build . && cmake --build . --target install
RUN /bin/cp -rf /usr/local/lib64/* /lib64/ && ldconfig

# Compile libgit2 (required for pygit2 + ed25519 support)
RUN git clone https://github.com/libgit2/libgit2.git /tmp/libgit2 && cd /tmp/libgit2 && git reset --hard 7321cff05df927c8d00755ef21289ec00d125c9c
RUN mkdir /tmp/libgit2/build
WORKDIR "/tmp/libgit2/build"
RUN cmake .. && cmake -DBUILD_SHARED_LIBS=ON --build . && cmake --build . --target install
RUN /bin/cp -rf /usr/local/lib/* /lib64/ && ldconfig

# Create virtualenv and install pygit2 under /tmp/pygit2
RUN mkdir /tmp/pygit2
RUN ls
WORKDIR "/tmp/pygit2"
RUN virtualenv .
RUN bash -c "source bin/activate && pip install --upgrade pip && pip install pygit2 && python -c 'import pygit2'"
CMD "/bin/bash"
