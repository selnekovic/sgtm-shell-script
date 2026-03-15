# Server-side GTM Deployment Script

A Bash script that automates deployment of a **Server-side Google Tag Manager (sGTM)** container to **Google Cloud Run**. 

It deploys two services:
- **Production service** (`-prod`) – main tagging server
- **Debug/Preview service** (`-preview`) – for debugging and container preview

---

## Usage

Run directly:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/selnekovic/sgtm-shell-script/main/sgtm_shell.sh)"
```

Or clone and run locally:

```bash
chmod +x sgtm_shell.sh
./sgtm_shell.sh
```

The script prompts for:

1. **Service Name** – name of the service (recommended: `sgtm-server-eu`, press Enter for default)
2. **Container Config** – paste the JSON config from GTM (required)

---

## What the script does

1. Deploys the **preview** service (`-preview`) first with smaller resources (256Mi RAM, 0–1 instances).
2. Then deploys the **production** service (`-prod`) with larger resources (512Mi RAM, 1–4 instances, 60s timeout).
3. Prints the production server URL and health check link at the end.

**Health check:** after deployment, test `https://<production-service-url>/healthy`.

## License and references

- **Author:** [Julius Selnekovic](https://selnekovic.com)  
- **License:** [MIT](LICENSE)  
- **Article:** [Server-side GTM Domain Mapping with Load Balancer](https://selnekovic.com/blog/sgtm-deployment-google-cloud-run/)
