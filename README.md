# setup-env
Automatized run-time environment setup script for PaiCoop.
> Only tested on `CentOS7.9.2009`!!

## Usage
Run `$ bash <(curl -s https://raw.githubusercontent.com/PaiCoop/setup-env/main/setup.sh)` to launch the script.

## Q&A

### No Response
Run `$ yum -y install nscd; systemctl start nscd; nscd -i hosts; echo '199.232.96.133    raw.githubusercontent.com'>>/etc/hosts` to prevent the DNS cache pollution. Then try the setup script again.
