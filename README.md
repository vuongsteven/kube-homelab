# kube-homelab

A Kubernetes home lab on Proxmox, built one lesson at a time. Each lesson deploys something useful and documents the concepts behind it.

## Lessons

| # | Lesson | What it teaches |
|---|---|---|
| 1 | [Uptime Kuma on k3s](docs/learning/01-uptime-kuma/README.md) | Deployments, persistent storage, Services, Ingress, health checks and resource limits |
| 2 | [AdGuard Home on k3s](docs/learning/02-adguard-home/README.md) | DNS, TCP and UDP, LoadBalancer Services, DNS rewrites and safe rollout |

## Layout

```
docs/learning/   Lesson write-ups
kubernetes/      Manifests, one folder per app
```

## No secrets in Git

Kubeconfig files and credentials stay out of this repository.
