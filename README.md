# kube-homelab

A Kubernetes home lab on Proxmox, built one lesson at a time. Each lesson deploys something useful and documents the concepts behind it.

📖 **Read it as a website:** <https://vuongsteven.github.io/kube-homelab/>

## Lessons

| # | Lesson | What it teaches |
|---|---|---|
| 1 | [Uptime Kuma on k3s](docs/learning/01-uptime-kuma/README.md) | Deployments, persistent storage, Services, Ingress, health checks and resource limits |
| 2 | [AdGuard Home on k3s](docs/learning/02-adguard-home/README.md) | DNS, TCP and UDP, LoadBalancer Services, DNS rewrites and safe rollout |

## Side lessons

Infrastructure around the cluster, done whenever it's useful.

| Lesson | What it teaches |
|---|---|
| [Dev VM with Terraform](docs/side-lessons/dev-vm/README.md) | Terraform, cloud-init, Proxmox permissions and firewalls, systemd, Claude Code Remote Control, Tailscale |

## Layout

```
docs/learning/       Kubernetes lesson write-ups
docs/side-lessons/   Side lesson write-ups
hooks/               Build hook that makes the docs site pick up new pages
kubernetes/          Manifests, one folder per app
terraform/           Terraform, one folder per project
tailscale/           Reference copy of the tailnet access policy
```

## The docs site

Everything under `docs/` is published to GitHub Pages with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) whenever `main` changes. There's no hand-written menu: the sidebar and the home page's lesson cards are built from the folders.

### Adding a lesson

1. Create a folder with a `README.md`, e.g. `docs/learning/03-something/README.md`. The number prefix sets the order.
2. Start it with a `# Title` heading and a one-paragraph summary. The heading becomes the sidebar entry and the card title on the home page; the first paragraph becomes the card text.
3. Push to `main`. The site rebuilds on its own.

A new top-level folder (say `docs/cheatsheets/`) becomes a new sidebar section and home page group automatically. To give it a nicer name or a blurb, add it under `section_titles` and `section_blurbs` in `mkdocs.yml`. Links to files outside `docs/`, like `../../../kubernetes/app/`, are turned into GitHub links.

### Previewing locally

```bash
pip install -r requirements-docs.txt
mkdocs serve
```

Then open <http://127.0.0.1:8000>. The CI build uses `mkdocs build --strict`, so a broken link fails the pull request.

## No secrets in Git

Kubeconfig files, credentials, `terraform.tfvars` and Terraform state stay out of this repository.
