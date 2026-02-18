FROM scratch as ctx
COPY build_scripts /

FROM ghcr.io/nushell/nushell:latest-alpine as nushell

FROM quay.io/fedora/fedora-bootc:42 as base

COPY --from=nushell /usr/bin/nu /usr/bin/nu
RUN printf '/bin/nu\n/usr/bin/nu' >> /etc/shells

COPY yum-repos/fury.repo /etc/yum.repos.d/fury.repo

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-base.sh

RUN bootc container lint --fatal-warnings


FROM quay.io/fedora/fedora-kinoite:43 as desktop

COPY --from=nushell /usr/bin/nu /usr/bin/nu
RUN printf '/bin/nu\n/usr/bin/nu' >> /etc/shells

COPY yum-repos/fury.repo /etc/yum.repos.d/fury.repo

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

RUN bootc container lint --fatal-warnings


FROM desktop as laptop

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=cache,dst=/var/lib/rpm-state \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-laptop.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-laptop.sh

RUN bootc container lint --fatal-warnings
