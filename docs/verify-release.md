# Verifying the Tekton Pipelines Package Release

This package is published as an OCI artifact, signed with Sigstore [Cosign](https://docs.sigstore.dev/cosign/overview), and associated with a [SLSA Provenance](https://slsa.dev/provenance) attestation.

Using `cosign`, you can display the supply chain security related artifacts for the `ghcr.io/kadras-io/package-for-cert-manager` images. Use the specific digest you'd like to verify.

```shell
cosign tree ghcr.io/kadras-io/package-for-cert-manager
```

The result:

```shell
📦 Supply Chain Security Related artifacts for an image: ghcr.io/kadras-io/package-for-cert-manager
└── 💾 Attestations for an image tag: ghcr.io/kadras-io/package-for-cert-manager:sha256-3cc778ffeb099e827e357518ea32e4e4b5688ea1ef947270139732bb8719c355.att
   └── 🍒 sha256:050052870dc08a4d59d9c59189d14f02c17e89e5c75e17b429263484190dfda5
└── 🔐 Signatures for an image tag: ghcr.io/kadras-io/package-for-cert-manager:sha256-3cc778ffeb099e827e357518ea32e4e4b5688ea1ef947270139732bb8719c355.sig
   └── 🍒 sha256:84b91f7dab26d39bf107e0b631f24baf3a6e74c13496a7e4ad0d314f21f784d4
```

You can verify the signature and its claims:

```shell
cosign verify \
   --certificate-identity-regexp https://github.com/kadras-io \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/package-for-cert-manager | jq
```

You can also verify the SLSA Provenance attestation associated with the image.

```shell
cosign verify-attestation --type slsaprovenance \
   --certificate-identity-regexp https://github.com/slsa-framework \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/package-for-cert-manager | jq .payload -r | base64 --decode | jq
```
