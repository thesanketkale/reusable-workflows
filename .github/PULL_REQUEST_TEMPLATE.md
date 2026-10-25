## Summary

Provide a concise description of the changes proposed in this pull request and the rationale behind them.

## Type of Change

- [ ] `feat`: A new reusable workflow, composite action, or capability
- [ ] `fix`: Bug fix in an existing workflow or script
- [ ] `docs`: Documentation updates or corrections in `docs/workflows/`
- [ ] `ci`: Improvements to repository CI, linters, or self-tests
- [ ] `chore`: Maintenance, dependency bump, or configuration update

## Verification Checklist

- [ ] All new or modified workflows pass `actionlint` locally without warnings
- [ ] All YAML files pass `yamllint -c .yamllint.yml .`
- [ ] Shell scripts pass `shellcheck`
- [ ] Documentation in `docs/workflows/<name>.md` matches workflow inputs (`bash scripts/check-docs.sh`)
- [ ] Self-test workflows execute and pass against fixtures
- [ ] Third-party actions are pinned to full 40-character commit SHAs with version comments
- [ ] Minimal permissions (`permissions: {}` / scoped per job) are enforced
