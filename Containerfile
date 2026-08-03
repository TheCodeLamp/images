FROM scratch as ctx
COPY build_scripts /

FROM ghcr.io/nushell/nushell:latest-alpine as nushell

FROM docker.io/library/rust:1-bookworm as helix-builder

ARG HELIX_COMMIT=079a789e8cb08ead67f19e1971a1b7438b37354b

RUN git clone https://github.com/helix-editor/helix /usr/src/helix \
    && cd /usr/src/helix \
    && git checkout ${HELIX_COMMIT}

WORKDIR /usr/src/helix

ENV HELIX_DEFAULT_RUNTIME=/usr/lib/helix/runtime

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/src/helix/target \
    cargo build --profile opt --locked \
    && cp target/opt/hx /usr/local/bin/hx

RUN --mount=type=cache,target=/usr/src/helix/target \
    mkdir -p /opt/helix/usr/bin /opt/helix/usr/lib/helix \
    && cp /usr/local/bin/hx /opt/helix/usr/bin/hx \
    && cp -r runtime /opt/helix/usr/lib/helix/runtime


FROM quay.io/fedora/fedora-bootc:44 as base

COPY --from=nushell /usr/bin/nu /usr/bin/nu
RUN printf '/bin/nu\n/usr/bin/nu' >> /etc/shells

COPY --from=helix-builder /opt/helix/usr/bin/hx /usr/bin/hx
COPY --from=helix-builder /opt/helix/usr/lib/helix /usr/lib/helix

COPY yum-repos/custom.repo /etc/yum.repos.d/custom.repo

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-base.sh

RUN bootc container lint


FROM quay.io/fedora/fedora-kinoite:44 as desktop

COPY --from=nushell /usr/bin/nu /usr/bin/nu
RUN printf '/bin/nu\n/usr/bin/nu\n' >> /etc/shells

COPY --from=helix-builder /opt/helix/usr/bin/hx /usr/bin/hx
COPY --from=helix-builder /opt/helix/usr/lib/helix /usr/lib/helix

COPY yum-repos/custom.repo /etc/yum.repos.d/custom.repo

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-desktop.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-desktop.sh

RUN bootc container lint


FROM quay.io/fedora/fedora-kinoite:43 as laptop

COPY dracut.conf /usr/lib/dracut/dracut.conf.d/50-custom-ostree.conf

COPY --from=nushell /usr/bin/nu /usr/bin/nu
RUN printf '/bin/nu\n/usr/bin/nu\n' >> /etc/shells

COPY --from=helix-builder /opt/helix/usr/bin/hx /usr/bin/hx
COPY --from=helix-builder /opt/helix/usr/lib/helix /usr/lib/helix

COPY yum-repos/custom.repo /etc/yum.repos.d/custom.repo

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-desktop.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-desktop.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=cache,dst=/var/lib/rpm-state \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-laptop.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-laptop.sh

RUN bootc container lint
