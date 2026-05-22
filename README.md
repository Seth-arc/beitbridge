# Beitbridge

`Beitbridge` is a static single-page interactive narrative. There is no build step and no application server in this repo. Production deployment means publishing `index.html` and the `img/` directory together as static assets.

## Deploy

1. Publish the repository root as a static site.
2. Keep `index.html` and `img/` at the same relative paths used in the repo.
3. Serve over HTTPS.
4. Cache `index.html` conservatively and cache `img/*.jpg` aggressively once you are comfortable with the asset filenames staying stable.
5. The current artifact keeps its CSS and JavaScript inline. If your production host enforces a strict Content Security Policy that disallows inline code, externalize those blocks before deploy or explicitly account for them in your CSP.

## GitHub Pages

This repo now includes a GitHub Pages workflow at `.github/workflows/deploy-pages.yml`.

1. Push the repository to the `main` branch on GitHub.
2. In the GitHub repository, open `Settings -> Pages`.
3. Set `Source` to `GitHub Actions` if it is not already selected.
4. After the push completes, wait for the `Deploy GitHub Pages` workflow to finish.
5. The default project-site URL shape is `https://<owner>.github.io/<repo>/`.

## Verification

Run the deploy contract check:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\production-contract.ps1
```

Run the GitHub Pages contract check:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\github-pages-contract.ps1
```

Manual browser checks:

1. Open `index.html` through your target static host or a local static server.
2. Press `Tab` on first load and confirm the skip link appears before the story controls.
3. Activate `Begin the Journey` and confirm focus moves to the new scene heading.
4. Progress until a choice becomes unaffordable and confirm the locked choice cannot be activated by keyboard or pointer.
5. Finish a route, activate `Try a Different Path`, and confirm focus returns to the start button.
6. Re-test with reduced motion enabled at OS/browser level and confirm the scene still changes without animation-heavy transitions.

## Release Notes

- The interactive buttons now use delegated event handling instead of inline `onclick` attributes.
- Scene changes announce themselves through a polite live region and move focus to the new heading.
- Decorative motion is suppressed when `prefers-reduced-motion: reduce` is active.
- The repository now includes a GitHub Actions workflow that publishes `index.html` and `img/` to GitHub Pages.
- This artifact still depends on Google Fonts at runtime. If your production environment blocks third-party font requests, self-host or replace those fonts before deploy.
- This artifact still uses inline CSS and JavaScript. A strict CSP rollout is a separate hardening step.
