# SBOM Summary — lab07

Generated from: `sbom.xml` (CycloneDX 1.6)  
SBOM timestamp: 2026-06-19

## Overview

| Metric | Value |
|---|---|
| Total dependencies | 3 |
| Outdated dependencies | 2 |
| SBOM format | CycloneDX XML 1.6 |

---

## Dependency Table

| Package | Min. Required | Latest | Category | Status |
|---|---|---|---|---|
| `bcrypt` | >=4.0.1 | 5.0.0 | Security — password hashing | ⚠️ Outdated (major version behind) |
| `pyyaml` | >=6.0.2 | 6.0.3 | Configuration / Data Serialization | ⚠️ Outdated (patch behind) |
| `requests` | >=2.32.3 | 2.34.2 | HTTP Client / Networking | ⚠️ Outdated (minor versions behind) |

---

## Dependency Categories

| Category | Packages |
|---|---|
| Security | `bcrypt` |
| Configuration / Serialization | `pyyaml` |
| HTTP / Networking | `requests` |

---

## Outdated Dependencies

> The SBOM records minimum version constraints from `requirements.txt`, not pinned installed versions.
> Versions below are compared against the PyPI latest releases as of 2026-06-19.

| Package | Min. Required | Latest | Notes |
|---|---|---|---|
| `bcrypt` | >=4.0.1 | 5.0.0 | Major version bump — review [changelog](https://github.com/pyca/bcrypt/blob/main/CHANGELOG.rst) for breaking changes and security fixes |
| `requests` | >=2.32.3 | 2.34.2 | Two minor versions behind — update recommended for security and bug fixes |
| `pyyaml` | >=6.0.2 | 6.0.3 | One patch behind — low risk, straightforward bump |

---

## Recommendations

1. **`bcrypt`** — Upgrade the minimum constraint to `>=5.0.0`. As a security library, staying on the latest major release is important.
2. **`requests`** — Bump to `>=2.34.2` to pick up security patches.
3. **`pyyaml`** — Bump to `>=6.0.3` (low effort, low risk).
4. Consider **pinning exact versions** (`==`) in a `requirements-lock.txt` or using `pip-compile` to ensure reproducible builds.
