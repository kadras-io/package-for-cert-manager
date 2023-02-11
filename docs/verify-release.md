# Verifying the Tekton Pipelines Package Release

This package is published as an OCI artifact, signed with Sigstore [Cosign](https://docs.sigstore.dev/cosign/overview), and associated with a [SLSA Provenance](https://slsa.dev/provenance) attestation.

Using `cosign`, you can display the supply chain security related artifacts for the `ghcr.io/kadras-io/package-for-cert-manager` images. Use the specific digest you'd like to verify.

```shell
COSIGN_EXPERIMENTAL=1 cosign tree ghcr.io/kadras-io/package-for-cert-manager
```

The result:

```shell
📦 Supply Chain Security Related artifacts for an image: ghcr.io/kadras-io/package-for-cert-manager
└── 💾 Attestations for an image tag: ghcr.io/kadras-io/package-for-cert-manager:sha256-76d5d060d8a864933699715d29ef3fdc805378ed47600e029b03aadad020e77e.att
   └── 🍒 sha256:2daae1cfdfb38b1a51cb7f273cac0081a2216017e4db5f78b4e1430fabcd99d1
└── 🔐 Signatures for an image tag: ghcr.io/kadras-io/package-for-cert-manager:sha256-76d5d060d8a864933699715d29ef3fdc805378ed47600e029b03aadad020e77e.sig
   └── 🍒 sha256:7390da18a629450c393c8ee9a9712e8bc27f1fbfedbd07312e54f57e9a6be5d5
```

You can verify the signature and its claims:

```shell
COSIGN_EXPERIMENTAL=1 cosign verify ghcr.io/kadras-io/package-for-cert-manager | jq
```

You can also verify the SLSA Provenance attestation associated with the image.

```shell
COSIGN_EXPERIMENTAL=1 cosign verify-attestation --type slsaprovenance ghcr.io/kadras-io/package-for-cert-manager | jq .payload -r | base64 --decode | jq
```
