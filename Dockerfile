FROM ubuntu:jammy
# Ubuntu 22.04 LTS

# Setup user mpst, add to sudoer
RUN useradd mpst \
  && echo "mpst:mpst" | chpasswd \
  && adduser mpst sudo \
  && mkdir /home/mpst \
  && chown mpst:mpst /home/mpst

# Install dependencies
RUN apt update \
  && apt install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    default-jdk \
    g++ \
    gcc \
    git \
    gnupg \
    libc6-dev \
    libffi-dev \
    libgmp-dev \
    make \
    netbase \
    sudo \
    vim \
    xz-utils \
    zlib1g-dev \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list \
  && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list \
  && curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import \
  && chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg \
  && apt-get update \
  && apt install -y --no-install-recommends \
    sbt \
  && curl -sSL https://get.haskellstack.org/ | sh \
  && rm -rf /var/lib/apt/lists/* /tmp/*

USER mpst
WORKDIR /home/mpst

RUN mkdir -p /home/mpst/Lib

COPY --chown=mpst:mpst \
  effpi /home/mpst/effpi/

COPY --chown=mpst:mpst \
  project /home/mpst/project/

COPY --chown=mpst:mpst \
  build.sbt /home/mpst/build.sbt

COPY --chown=mpst:mpst \
  Teatrino /home/mpst/Lib/Teatrino/

RUN cd Lib/Teatrino \
  && export LANG=C.UTF-8 \
  && stack build :Teatrino :Teatrino-bench --dependencies-only \
  && stack build Teatrino \
  && stack install

RUN sbt compile

RUN cp -r /home/mpst/Lib/Teatrino/scribble /home/mpst/examples

COPY --chown=mpst:mpst \
  runScala.sh /home/mpst/runScala.sh

COPY --chown=mpst:mpst \
  genAll.sh /home/mpst/genAll.sh

RUN chmod +x \
  /home/mpst/runScala.sh \
  /home/mpst/genAll.sh

COPY --chown=mpst:mpst \
  README.md /home/mpst/README.md

ENV PATH="${PATH}:/home/mpst/.local/bin"

