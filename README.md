# kube-homelab

A Kubernetes home lab on Proxmox, built one lesson at a time. Each lesson deploys something useful and documents the concepts behind it.

## Lessons

| # | Lesson | What it teaches |
|---|---|---|
| 1 | [Uptime Kuma on k3s](docs/learning/01-uptime-kuma/README.md) | Deployments, persistent storage, Services, Ingress, health checks and resource limits |
| 2 | [AdGuard Home on k3s](docs/learning/02-adguard-home/README.md) | DNS, TCP and UDP, LoadBalancer Services, DNS rewrites and safe rollout |

## Side lessons

Infrastructure around the cluster, done whenever it's useful.

| Lesson | What it teaches |
|---|---|
| [Dev VM with Terraform](docs/side-lessons/dev-vm/README.md) | Terraform, cloud-init, Proxmox permissions and firewalls, systemd, Claude Code Remote Control |

## Layout

```
docs/learning/       Kubernetes lesson write-ups
docs/side-lessons/   Side lesson write-ups
kubernetes/          Manifests, one folder per app
terraform/           Terraform, one folder per project
```

## No secrets in Git

Kubeconfig files, credentials, `terraform.tfvars` and Terraform state stay out of this repository.
