# Fix Old Commit Author Names

Rewrites all commits to use a consistent author name/email, then force-pushes.

## Prerequisites

`git-filter-repo` must be available:

```bash
nix shell nixpkgs#git-filter-repo
```

## Steps

1. **Rewrite history**

```bash
git filter-repo \
  --name-callback 'return b"MaySeikatsu"' \
  --email-callback 'return b"maynoshinseikatsu@gmail.com"'
```

2. **Re-add the remote** (filter-repo removes it as a safety measure)

```bash
git remote add origin https://github.com/MaySeikatsu/nixos-config.git
```

3. **Force-push**

```bash
git push --force-with-lease origin main
```

## Notes

- All commit SHAs change — any external links to specific commits will break
- GitHub's contribution graph will backfill once the email matches your verified GitHub email
