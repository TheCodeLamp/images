FROM scratch as ctx
COPY build_scripts /

FROM ghcr.io/nushell/nushell:latest-alpine as nushell

FROM quay.io/fedora/fedora-bootc:42 as base

COPY --from=nushell /usr/bin/nu /usr/bin/nu
RUN printf '/bin/nu\n/usr/bin/nu' >> /etc/shells

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/clean-base.sh

RUN bootc container lint --fatal-warnings


FROM base as desktop

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-desktop.sh

RUN bootc container lint --fatal-warnings


FROM desktop as laptop

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/install-laptop.sh

# https://docs.fedoraproject.org/en-US/bootc/initramfs/#_regenerating_the_initrd
RUN set -xe; kver=$(ls /usr/lib/modules); env DRACUT_NO_XATTR=1 dracut -vf /usr/lib/modules/$kver/initramfs.img "$kver"

RUN bootc container lint --fatal-warnings
