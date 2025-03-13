# acme.sh.dnsexit
dnsapi script for dnsexit.com that runs without root and accpets the key via DNSEXITAPIKEY environment variable.

We use "dns_localdnsexit.sh" to avoid conflicting with the insecure official dnsexit client.  Unfortunately, to be accepted by the project the script must be insecure so this script will not be included in the official acme.sh

Create an API key on dnsexit.com

Copy dns_localdnsexit.sh to /home/user/.acme.sh/dnsapi/

export DNSEXITAPIKEY=[your api key]

To issue a certificate:
.acme.sh/acme.sh --debug 2 --issue --dns dns_localdnsexit --ecc --server letsencrypt -d yourdomain.com -d *.yourdomain.com

To renew a certificate:
.acme.sh/acme.sh --debug 2 --renew --dns dns_localdnsexit --ecc --server letsencrypt -d yourdomain.com -d *.yourdomain.com

Optionally put your key and domains in /etc/acme/acme.env and put acme-renew.service and acme-renew.timer in /etc/systemd/system/

The acme.env variables are DNSEXITAPIKEY=[your api key] and DOMAINS="domain1.com domain2.com"

The systemd files here assume you have an unprivlidged user named acme with acme.sh installed in ~/.acme.sh
For security, do not put a password on this account and do not allow it to create one. (spoilers, there are bugs in Linux)

To enable the systemd files:
systemctl daemon-reload
systemctl enable acme-renew.timer
systemctl start acme-renew.timer
