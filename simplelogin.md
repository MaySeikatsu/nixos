claude --resume ed0323f5-a5b2-4236-a9ca-aeaab052b6ce

Yes, SimpleLogin is fully self-hostable and open source. Here's a summary of what you need:

Requirements

Server:

- A Linux server (VM or dedicated) with at least 2 GB RAM
- Ports 25 (SMTP), 80, 443, 22 open

Software (all Docker-based):

- Docker + Docker Compose
- Postgres 12+
- Postfix + postfix-pgsql (for mail handling)

Domain/DNS:

- A domain you fully control (can be a subdomain)
- Two hostnames: one for email (e.g. mail.domain.com) and one for the webapp (e.g. app.domain.com)
- DNS records: MX, A, TXT (SPF, DKIM, DMARC), CNAME

Key challenge

Port 25 is the usual blocker — most residential ISPs and many VPS providers block outbound port 25 to prevent spam. You'll want a VPS that explicitly allows it (Hetzner, for example, allows it after a support request).

Setup approach

The official repo is simple-login/app (https://github.com/simple-login/app) but community Docker Compose setups like springcomp/self-hosted-simplelogin (https://github.com/springcomp/self-hosted-simplelogin) make it significantly easier to get running.

Since you're on NixOS, you'd likely want to wrap this in a NixOS module or Arion/Docker Compose config rather than raw Docker — want me to look into what that would take?

Sources:

- simple-login/app on GitHub (https://github.com/simple-login/app)
- springcomp/self-hosted-simplelogin (https://github.com/springcomp/self-hosted-simplelogin)
- Self-Hosting Deployment Guide (DeepWiki) (https://deepwiki.com/simple-login/app/10.4-self-hosting-deployment-guide)

---

NixOS Approach

No official nixpkgs module exists yet (there's an open issue #371829 (https://github.com/NixOS/nixpkgs/issues/371829)). The most idiomatic NixOS options are:

1. virtualisation.oci-containers — NixOS's built-in way to declaratively run containers, defaults to Podman. You'd translate the docker-compose into individual container definitions in your NixOS config.
2. Arion — Nix wrapper around Docker Compose that uses the NixOS module system. Lets you write Compose-style configs in Nix syntax.
3. Raw Postfix NixOS module — NixOS has excellent services.postfix support, so the mail layer could be native, with only the webapp containerized.

For a local test, option 1 is probably the easiest path.

---

Podman Instead of Docker

Yes, should work. NixOS's virtualisation.oci-containers uses Podman by default and is compatible with Docker image formats. podman-compose is a drop-in for docker-compose. The main gotcha: rootless Podman can't bind port 25 (ports below 1024 require root or a sysctl tweak). You'd need either:

- net.ipv4.ip_unprivileged_port_start=25 in your kernel params, or
- run the mail container as root/via podman --rootful

---

Can you use mayseikatsu.simplelogin.com?

No. That subdomain is provisioned by SimpleLogin's hosted service — you don't control the simplelogin.com DNS zone and can't set MX records pointing to your machine. Self-hosting requires a domain you fully own where you can configure:

- MX record → your server's IP
- SPF, DKIM, DMARC TXT records

You'd need your own domain (e.g. from Namecheap, Cloudflare, etc.). A subdomain of a domain you own works fine.

---

Deutsche Telekom + Port 25

Port 25 is blocked by Telekom for residential connections — this is confirmed by multiple Telekom community forum threads. They block it to prevent spam from infected home machines. This is standard practice for German residential ISPs.

Implications for local testing:

- You cannot receive inbound SMTP from the internet on port 25 at home — meaning real email forwarding won't work end-to-end
- For a local functional test (just seeing the UI, alias creation, account management), it's still fine
- For actual mail flow testing, you'd need a VPS or to relay through an SMTP service

Security concern of hosting on home network: Even if port 25 weren't blocked, exposing an SMTP server from home is genuinely risky — your home IP could get blacklisted by spam filters, and misconfiguring Postfix as an open relay is a common mistake. For production, a VPS is the right call anyway.

---

Summary Recommendation

For local testing: set up with virtualisation.oci-containers + Podman, test the web UI and alias management, but don't expect real email delivery to work through Telekom. Once it looks good, deploy to a VPS (Hetzner is popular in Germany and allows port 25 after a quick support request) with a domain you own.

Want me to sketch out the NixOS oci-containers config for SimpleLogin's stack?

Sources:

- nixpkgs SimpleLogin package request (https://github.com/NixOS/nixpkgs/issues/371829)
- springcomp/self-hosted-simplelogin (https://github.com/springcomp/self-hosted-simplelogin)
- Telekom port 25 community thread (https://telekomhilft.telekom.de/conversations/festnetz-internet/bitte-smtp-port-25-an-meinem-anschluss-freizuhalten/6686f2ee4ae73561da8762a8)
- Port 25 blocked diagnosis (https://www.captaindns.com/en/blog/port-25-blocked-diagnosis-solutions)
- SimpleLogin subdomain MX discussion (https://github.com/simple-login/app/discussions/1272)
