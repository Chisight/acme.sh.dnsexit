# acme.sh.dnsexit

acme.sh dnsapi script for dnsexit.com that runs without root and accepts the API key via DNSEXITAPIKEY environment variable.  For security the API variable will **_not_** be saved in ~/.acme.sh/account.conf or anywhere else accessible by the acme account and the login/password are not used.  Without the login, we have to guess at what exactly is registered so may fail to recognize some unusual domain naming structures.

A dnsapi script allows you to create wildcard certificates like *.yourdomain.com which match any hostname in your domain.  Note, the bare yourdomain.com host is not included in the wildcard *.yourdomain.com so, as in the examples below, you specify it directly.

Note, since we run without root, the acme.sh options for updating webserver configs will not work so manually point your webserver to the certificates created. We need the API key in an enviornment variable, so do not enable the cronjob as it won't have the key.  systemd configs are provided instead.

We use "dns\_localdnsexit.sh" to avoid conflicting with the insecure official dnsexit client. Unfortunately, to be accepted by the project the script must pass insecure tests so this script will not be included in the official acme.sh

Create an API key on dnsexit.com

`cp dns_localdnsexit.sh /home/acme/.acme.sh/dnsapi/`

`export DNSEXITAPIKEY=[your api key]`

To issue a certificate: `.acme.sh/acme.sh --debug 2 --issue --dns dns_localdnsexit --ecc --server letsencrypt -d yourdomain.com -d *.yourdomain.com`

To renew a certificate: `.acme.sh/acme.sh --debug 2 --renew --dns dns_localdnsexit --ecc --server letsencrypt -d yourdomain.com -d *.yourdomain.com`

To avoid leaking information across domains, run `-d yourdomain1.com -d *.yourdomain1.com` and `-d yourdomain2.com -d *.yourdomain2.com` as separate commands.  This runs slower but someone knowing yourdomain1.com won't automatically know yourdomain2.com is operated by the same entity.  The systemd configs provided assume this and do not handle multiple domains on a single certificate.

Optionally put your key and domains in `/etc/acme/acme.env` and `cp acme-renew.service acme-renew.timer /etc/systemd/system/`

acme-renew.service assumes nginx, edit `After=` and `ExecStartPost=` for other webservers.

The acme.env variables are:

```
DNSEXITAPIKEY=[your api key]
DOMAINS="domain1.com domain2.com"
```

Secure your environment file with `chmod 600 /etc/acme/acme.env`

The systemd files here assume you have an unprivileged user named `acme` with acme.sh installed in ~/.acme.sh

For security, do not put a password on this account and do not allow it to create one. (spoilers: there are bugs in Linux)

To enable the systemd files:

```
systemctl daemon-reload
systemctl enable acme-renew.timer
systemctl start acme-renew.timer
```
