FROM scratch as ctx
COPY build_scripts /

FROM quay.io/fedora/fedora-bootc:42 as base

COPY yum-repos/custom.repo /etc/yum.repos.d/custom.repo

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-base.sh

RUN bootc container lint --fatal-warnings


FROM quay.io/fedora/fedora-kinoite:42 as desktop

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
