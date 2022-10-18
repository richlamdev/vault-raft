# HashiCorp Vault PKI with Raft backend

* [Introduction](#introduction)
* [Purpose](#purpose)
* [Prerequisites](#prerequisites)
   * [Operating System](#operating-system)
   * [Knowledge](#knowledge)
   * [Software](#software)


## Introduction

This repo demonstrates [HashiCorp's Vault](https://www.hashicorp.com/products/vault)
product as a Certificate Authority (CA) for Public Key Infrastructure (PKI).
This demo utilizes a raft as a [storage backend](https://www.vaultproject.io/docs/configuration/storage) 
as opposed to a file backend which is typical in many demos/tutorials.
Deploying Vault with raft backend allows for simple backup and recovery of data via
built-in commands.  While there are other features with a raft deployment, convienent 
backup and restoration were significant factors for using raft as a backend.  Technically,
raft is a [consensous algorithm](https://raft.github.io/), but I digress...


## Purpose

The primary purpose is to provide a development/test environment to learn PKI with HashiCorp Vault.

This repo (platform) could potentially be used for personal/private networks, if you accept
the shortcomings.  The limitations are the lack comprehensive features and proper deployment
of HashiCorp raft backend infrastructure.


## Prerequisites

### Operating System

- Developed on Ubuntu Linux 22.04 LTS.
- Tested with Bash Shell

Naturally this repo will work with other \*nix Operating Systems and/or Shells with modification.

### Software

- [HashiCorp Vault](https://www.vaultproject.io/downloads)
- [Jq](https://stedolan.github.io/jq/download/)
- [OpenSSL](https://wiki.openssl.org/index.php/Binaries)

### Optional, but preferred - this enables convenient copy and paste of root token to login to Vault. (either CLI and/or GUI)
- [xclip](https://github.com/astrand/xclip)

### Knowledge

- Basic understanding of TLS certificates.  If knowledge is limited; this
  platform is great to learn and play with TLS certificates and Certificate Authority (CA)

- Basic understanding of [HashiCorp Vault](https://www.vaultproject.io/).

- Basic knowledge of Linux command line and BASH scripting.


## Quick Start

Clone the Repo:\
```git clone https://github.com/richlamdev/vault-pki-raft.git```\
```cd vault-pki-raft```

Steps:\
```./raft start```\
```./create_root_inter_certs.sh```\
```./issue_cert_template.sh```

## Quick Start Explanation

The above will perform the following:\
**1. Deploys a single Vault instance with a raft backend. - [raft.sh]**

    a. This will unseal the vault and login in the current terminal as the root
       user.

    b. This will save the unseal key and root token in the current folder.

**2. Enables Vault PKI Engine and creates a CA - [create_root_inter_certs.sh]**

    a. Creates a root certificate and self sign the certificate.
       The root CA is designated by the variable ISSUER_NAME_CN.
       By default the ISSUER_NAME_CN is "Lord of the Rings".
       Change this value as you like.

    b. Creates an intermediate certificate signing request, have the root 
       authority sign this certificate and store it within the CA.

    c. Creates a role designated by the variable VAULT_ROLE to sign leaf 
       certificates.  Note the value of VAULT_ROLE, itself, is not critical.
       However, the VAULT_ROLE value must be the same in both files, 
       create_root_inter_certs.sh and issue_cert_template.sh.  This role name 
       is referenced (used) to sign leaf certificates.  If they do not match, 
       an error will occur. Change this value if you like, just keep them 
       consistent.  VAULT_ROLE is authorized to sign subdomains indicated by
       the variable DOMAIN, in this case the Second Level Domain (SLD) and 
       Top Level Domain(TLD), the default value is "middleearth.test".  Again,
       change this value as you like.

    d. The self-signed CA root certificate and intermediate certificate chain
       are stored in the directory as designated by the variable 
       $ROOT_INTER_DIR.  The directory default is "./root_inter_certs".
       Import the root certificate from this folder to your Operating System 
       Trusted Store or Web Browser.  If you're unaware how to import the root
       certificate to either, a quick google search will help you.

**3. Issue a \"template\" certificate with a default Subject Common Name (CN)
     template.middleearth.test - [issue_cert_template.sh]**

    a. The resulting public certificate, key file, as well as entire signed 
       json blob is stored in directory designated by the variable SUBJECT_CN.
       Edit the HOST and DOMAIN variables to change the default value of
       SUBJECT_CN.  Ensure the value of DOMAIN is the same in both files,
       create_root_inter_certs.sh and issue_cert_template.sh.  In this example,
       the resulting certificate files will be stored in the directory 
       ```template.middleearth.test```.
<br/>

Inspecting template.middleearth.test certificate via openssl command:

![OpenSSL Inpection](images/openssl_inspection_certificate.png)
<br/>
<br/>

Optionally deploy the template certificate to a web server for inspection via
web browser.  The below is taken from Nginx in a Ubuntu Virtual Machine
(VM).  Naturally, alternatives would achieve similar results, such as Docker 
with Apache or Nginx, Windows & IIS etc.  The certificate inpsected via Firefox
browser:
![Firefox2](images/firefox_certificate2.png)
<br/>
<br/>

If you import the root certificate to your trusted store or browser update your
local DNS (or update local /etc/hosts file) to resolve 
template.middleaearth.test you will observe the certificate is trusted, denoted 
by the locked padlock symbol in your browser:
![DNS](images/trusted_certificate_DNS.png)
<br/>
<br/>

Furthermore, because the template script populates an IP address in the Subject
Alternative Name (SAN) we have "trust" established when visiting the web URL
via IP.  Note, it's atypical to deploy and IP in the SAN for public
certificates, however, for internal/private networks this is your discretion.

![IP SAN](images/trusted_certificate_SAN_IP.png)
<br/>
<br/>

If the root certificate is _not_ imported to the Web browser or added to the 
Operating System trusted store, then an error similar to this will appear:
![Certificate error](images/not_trusted_certificate_dns.png)
<br/>
<br/>


## Creating custom leaf certificates

With minimal changes, custom leaf certificates can be generated with these
scripts.

**Subdomain:**\
Edit HOST variable (aka subdomain) in issue_cert_template.sh.

**Domain:**\
Edit DOMAIN variable in create_root_inter_certs.sh and issue_cert_template.sh.

**IP Address - Subject Alternative Name:**\
Edit IP_SAN1 variable in issue_cert_template.sh.
Optionally omit this variable to remove a IP entry in the SAN.


---OPTIONAL VARIABLES---

**Certificate Authority (Issuer):**\
Edit the ISSUER_NAME_CN variable in create_root_inter_certs.sh.

**TTL:**\
Edit the TTL variable (aka expiry) to adjust the validity period of the
certificate in issue_cert_template.sh. This number is set in hours, per valid
by Vault software.

Presently the TTL is set for 9552 hours or 398 days.  Set to 398 days as per
default expiry for public leaf certificates governed by major browser 
manufacturers, Google, Apple, and Mozilla.  More often than not, many public 
certificates have a one year maximum validity period. (sometimes less, in 
the case of automated certifcate renewals, such as Let's Encrypt).  
Naturally, in the case of development or private environment set the length to
your desire.  Note that it cannot exceed the TTL of the root CA, which is
default 10 years.  Refer to References section below for more information.


## Save Vault state (save snapshot)

To make a backup, or a snapshot of any certifcates (secrets) stored in Vault
run the following command:
```./raft save```

This will save the state in the current folder under a folder named
*backup_xxxx*.  Where xxxx is a random identifier generated.  The purpose
of the unique identifier is to distinguish between multiple saved states.

Each backup folder will contain three files:
-the snapshot file itself, named snapshotxxxx
-the unseal key, saved in the file named unseal_keyxxxx
-the root token, saved in the file named root_tokenxxxx

Note, when a snapshot is taken, the matching unseal key and root token
must be used to access the vault after a snapshot is restored.  This is 
eseentially completed transparently by this script.  Refer to below
Restore section for more information.


## Restore Vault state (restore snapshot)

To restore a backup, or a snap of any previously saved state run the following
command:\
```./raft restore backup_xxxx```



## Revocation


## Improvements


## Security Concerns


## References
[HashiCorp Storage Backend](https://www.vaultproject.io/docs/configuration/storage)\
[HashiCorp Vault Backup](https://learn.hashicorp.com/tutorials/vault/sop-backup)\
[HashiCorp Vault Restore](https://learn.hashicorp.com/tutorials/vault/sop-restore)\
[smallstep PKI article](https://smallstep.com/blog/everything-pki/)\
[Mozilla Blog - Public Certificate Expiry](https://blog.mozilla.org/security/2020/07/09/reducing-tls-certificate-lifespans-to-398-days/)
