FROM scratch as ctx
COPY build_scripts /

FROM quay.io/fedora/fedora-bootc:44 as base

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
