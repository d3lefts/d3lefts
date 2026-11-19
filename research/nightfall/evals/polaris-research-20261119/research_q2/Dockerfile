# ProofGraph-Hard Q2 evaluation environment, PRELIMINARY build recipe.
# Not a certified image. After independent image review, publish by immutable
# registry digest, e.g. registry.example/polaris-q2@sha256:<64 hex>.
# Do not run agents or Lean metaprograms during image build.
FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
ARG LEAN_VERSION=v4.36.0-rc2
ARG LEAN_COMMIT=b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a
ARG MATHLIB_COMMIT=9d581dfff2e41de989072ea63abf3daf69311520

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl git python3 unzip zstd xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV ELAN_HOME=/opt/elan
ENV PATH=/opt/elan/bin:$PATH
RUN curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -o /tmp/elan-init.sh \
    && sh /tmp/elan-init.sh -y --no-modify-path --default-toolchain leanprover/lean4:${LEAN_VERSION} \
    && lean --version | grep -F "version ${LEAN_VERSION#v}" \
    && lean --version | grep -F "${LEAN_COMMIT}" \
    && lake --version

RUN git clone --depth 1 --branch "${LEAN_VERSION}" \
      https://github.com/leanprover-community/mathlib4.git /opt/mathlib4 \
    && test "$(git -C /opt/mathlib4 rev-parse HEAD)" = "${MATHLIB_COMMIT}" \
    && test "$(cat /opt/mathlib4/lean-toolchain)" = "leanprover/lean4:${LEAN_VERSION}" \
    && cd /opt/mathlib4 \
    && lake exe cache get \
    && test -f .lake/build/lib/lean/Mathlib.olean

RUN useradd -u 10001 -m -s /bin/sh polaris \
    && chmod -R a+rX /opt/mathlib4 /opt/elan
USER 10001:10001
WORKDIR /task
CMD ["sh"]
