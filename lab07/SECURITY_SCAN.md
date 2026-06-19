# Security Scan Report — lab07/requirements.txt

**Scan date:** 2026-06-19  
**Tool:** Manual CVE analysis (CycloneDX SBOM + advisory databases)  
**File scanned:** `lab07/requirements.txt`

---

## Summary

| Metric | Count |
|--------|-------|
| Packages scanned | 4 |
| CRITICAL | 2 |
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 1 |
| Unpinned packages | 3 |

---

## Findings

| Package | Current Version | CVE ID | Severity | Description |
|---------|----------------|--------|----------|-------------|
| `requests` | 2.18.0 | CVE-2018-18074 | MEDIUM | `Authorization` header forwarded to redirect target when redirected from HTTPS → HTTP, leaking credentials to unintended hosts. Fixed in 2.20.0. |
| `requests` | 2.18.0 | CVE-2023-32681 | MEDIUM | `Proxy-Authorization` header leaked to destination server when following cross-host redirects. Fixed in 2.31.0. |
| `pyyaml` | unpinned | CVE-2017-18342 | CRITICAL | `yaml.load()` without an explicit `Loader` allows arbitrary Python object deserialization → remote code execution. Fixed in 5.1 (Loader argument required). |
| `pyyaml` | unpinned | CVE-2020-14343 | CRITICAL | `yaml.full_load()` bypass via crafted YAML input allows unsafe deserialization. Fixed in 5.4. |
| `bcrypt` | unpinned | — | LOW | No known CVEs in recent releases, but unpinned version allows silent downgrades to vulnerable older builds. Pin to `>=4.0.1`. |
| `pytest` | unpinned | — | INFO | Test-only dependency with no known production CVEs. Should not be present in a production requirements file; move to `requirements-dev.txt`. |

---

## Remediation Plan

### Immediate (before merge)

1. **Upgrade `requests`** — the pinned version 2.18.0 carries two known CVEs:
   ```
   requests>=2.32.3
   ```

2. **Pin `pyyaml` with a safe minimum** — versions below 5.4 allow RCE via deserialization:
   ```
   pyyaml>=6.0.2
   ```
   Ensure all call sites use `yaml.safe_load()`, never bare `yaml.load()`.

3. **Pin `bcrypt`** — prevent silent downgrades:
   ```
   bcrypt>=4.0.1
   ```

### Before next release

4. **Separate test dependencies** — move `pytest` out of the main requirements file:
   ```bash
   # requirements.txt       — runtime only
   # requirements-dev.txt   — pytest and other dev tools
   ```

### Resulting `requirements.txt`

```
bcrypt>=4.0.1
pyyaml>=6.0.2
requests>=2.32.3
```

---

> **Note:** This report is based on advisory databases current as of 2026-06-19.
> Re-run `grype sbom:sbom.xml` after updating dependencies to confirm no residual findings.
