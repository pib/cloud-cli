FROM alpine:3.8 AS build

# Get precompiled tools
RUN mkdir -p /tools/bin && mkdir -p /tools/zips
RUN wget -nv -P /tools/bin \
    https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl \
    https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
RUN wget -nv -P /tools/zips \
    https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
RUN tar -C /tools/bin -xvf /tools/zips/helm-*.tar.gz

# Ensure all the various downloaded binaries are marked executable
RUN chmod +x /tools/bin/*


# Based partially on the mesosphere/aws-cli Dockerfile
FROM alpine:3.8

RUN apk add --no-cache --update \
      bash \
      ca-certificates \
      libc6-compat \
      postgresql-client \
      openssl \
      coreutils \
      python \
      py-pip \
      groff \
      less \
      mailcap \
      jq \
      && \
    pip install --upgrade awscli s3cmd python-magic && \
    apk --no-cache --purge del py-pip

# Copy in all the needed executables
COPY --from=build /tools/bin/* /bin/

VOLUME /root/.aws
VOLUME /project
WORKDIR /project

ENTRYPOINT ["/bin/bash"]
