# Security Scan Report

**Scanned file:** `requirements.txt`  
**Data source:** [OSV.dev](https://osv.dev) (Open Source Vulnerabilities)  
**Scan date:** 2026-06-19

---

## Summary

| Metric | Value |
|---|---|
| Total packages scanned | 3 |
| Packages with findings | 1 |
| Total CVEs found | 2 |
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 0 |

> **Note:** The `requirements.txt` uses minimum version constraints (`>=`) rather than pinned versions.
> Findings below represent vulnerabilities present at the **minimum allowed version** for each package.

---

## Findings

### `requests` — 2 vulnerabilities at minimum version 2.32.3

---

#### CVE-2024-47081 — `.netrc` Credentials Leak via Malicious URLs

| Field | Detail |
|---|---|
| **Package** | `requests` |
| **Affected version** | `< 2.32.4` (minimum in requirements: `2.32.3`) |
| **Fixed in** | `2.32.4` |
| **CVE ID** | [CVE-2024-47081](https://nvd.nist.gov/vuln/detail/CVE-2024-47081) |
| **GHSA** | [GHSA-9hjg-9r4m-mvj7](https://github.com/advisories/GHSA-9hjg-9r4m-mvj7) |
| **CVSS v3 Score** | 5.3 (MEDIUM) |
| **Severity** | **MEDIUM** |
| **Vector** | `AV:N/AC:H/PR:N/UI:R/S:U/C:H/I:N/A:N` |

**Description:** When a request is made using a URL that contains an `@` character in the host portion, `requests` incorrectly parses it and may send `.netrc` credentials to an unintended host, leaking authentication credentials to a third-party server under attacker control.

**Recommended action:** Bump minimum constraint to `requests>=2.32.4`.

---

#### CVE-2026-25645 — Insecure Temporary File Reuse in `extract_zipped_paths()`

| Field | Detail |
|---|---|
| **Package** | `requests` |
| **Affected version** | `< 2.33.0` (minimum in requirements: `2.32.3`) |
| **Fixed in** | `2.33.0` |
| **CVE ID** | [CVE-2026-25645](https://nvd.nist.gov/vuln/detail/CVE-2026-25645) |
| **GHSA** | [GHSA-gc5v-m9x4-r6x2](https://github.com/advisories/GHSA-gc5v-m9x4-r6x2) |
| **CVSS v3 Score** | 4.0 (MEDIUM) |
| **Severity** | **MEDIUM** |
| **Vector** | `AV:L/AC:H/PR:L/UI:R/S:U/C:N/I:H/A:N` |

**Description:** The `extract_zipped_paths()` utility function writes to a predictable temporary file path. A local attacker can pre-create the target path (symlink attack / TOCTOU race), causing the extracted content to be written to an arbitrary location, enabling local privilege escalation or file overwrite.

**Recommended action:** Bump minimum constraint to `requests>=2.33.0` (resolves both `requests` CVEs above).

---

### `bcrypt` — No vulnerabilities found

| Package | Min. Required | CVEs |
|---|---|---|
| `bcrypt` | `>=4.0.1` | None found in OSV |

---

### `pyyaml` — No vulnerabilities found at required version

| Package | Min. Required | CVEs at >=6.0.2 |
|---|---|---|
| `pyyaml` | `>=6.0.2` | None (all known CVEs fixed before 5.4) |

> Historical note: PyYAML has 8 CVEs in OSV total, all remediated by version 5.4. The minimum requirement of `>=6.0.2` is unaffected.

---

## Remediation Plan

### Priority 1 — MEDIUM (address within current sprint)

**Fix both `requests` CVEs in a single change:**

```diff
- requests>=2.32.3
+ requests>=2.33.0
```

This single bump resolves:
- CVE-2024-47081 (fixed in 2.32.4)
- CVE-2026-25645 (fixed in 2.33.0)

### Priority 2 — Harden version pinning (address in next sprint)

Using minimum constraints (`>=`) means any install at the minimum version is vulnerable until manually upgraded. Consider pinning exact versions via a lockfile:

```bash
pip install pip-tools
pip-compile requirements.txt --output-file requirements.lock
```

Commit `requirements.lock` and use it in production and CI:

```bash
pip install -r requirements.lock
```

### Priority 3 — Automate future scanning

Integrate OSV scanning into CI to catch new CVEs on every dependency update:

```bash
pip install pip-audit
pip-audit -r requirements.txt
```

Or add to the GitHub Actions workflow:

```yaml
- name: Security audit
  run: pip-audit -r requirements.txt --format markdown
```

---

## References

| CVE | OSV | NVD |
|---|---|---|
| CVE-2024-47081 | [GHSA-9hjg-9r4m-mvj7](https://github.com/advisories/GHSA-9hjg-9r4m-mvj7) | [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2024-47081) |
| CVE-2026-25645 | [GHSA-gc5v-m9x4-r6x2](https://github.com/advisories/GHSA-gc5v-m9x4-r6x2) | [nvd.nist.gov](https://nvd.nist.gov/vuln/detail/CVE-2026-25645) |
