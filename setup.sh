# registry server side

reg_path="./auth/registry.passwd"

if ! test -f "$reg_path"; then
    cd auth
    htpasswd -Bc registry.passwd gubr
    cd ..
fi



mkdir -p /etc/docker/certs.d/xreasy-db-lnx.cisco.com/

rm -f /etc/docker/certs.d/xreasy-db-lnx.cisco.com/*


openssl req \
  -newkey rsa:4096 -nodes -sha256 -keyout /etc/docker/certs.d/xreasy-db-lnx.cisco.com/domain.key \
  -addext "subjectAltName = DNS:xreasy-db-lnx.cisco.com" \
  -subj '/C=IN/ST=KARNTAKA/L=Banglore/O=Ciscoy/OU=XReasyOnBoard/CN=xreasy-db-lnx.cisco.com' \
  -x509 -days 365 -out /etc/docker/certs.d/xreasy-db-lnx.cisco.com/domain.crt

cp /etc/docker/certs.d/xreasy-db-lnx.cisco.com/* ./auth/ -f

# cp ./nginx/ssl/selfsigned.crt /etc/docker/certs.d/xreasy-db-lnx.cisco.com/



mkdir -p /usr/share/ca-certificates/extra/
mkdir -p /usr/local/share/ca-certificates/
mkdir -p /etc/pki/ca-trust/source/anchors/
cp /etc/docker/certs.d/xreasy-db-lnx.cisco.com/domain.crt /usr/share/ca-certificates/extra/xreasy-db-lnx.cisco.com.crt -f
cp /etc/docker/certs.d/xreasy-db-lnx.cisco.com/domain.crt /usr/local/share/ca-certificates/xreasy-db-lnx.cisco.com.crt -f
cp /etc/docker/certs.d/xreasy-db-lnx.cisco.com/domain.crt /etc/pki/ca-trust/source/anchors/xreasy-db-lnx.cisco.com.crt -f
update-ca-trust
update-ca-trust enable

echo '
        {
            "allow-nondistributable-artifacts": ["myregistrydomain.com:5000"],
            "insecure-registries" : ["xreasy-db-lnx.cisco.com:443"]
        }
    ' > /etc/docker/daemon.json

systemctl restart docker

docker-compose stop
docker-compose down
docker-compose up -d


# client side

# mkdir -p  /etc/docker/certs.d/xreasy-db-lnx.cisco.com/
# openssl s_client -showcerts -connect xreasy-db-lnx.cisco.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/docker/certs.d/xreasy-db-lnx.cisco.com/domain.crt
# echo '{"insecure-registries" : ["xreasy-db-lnx.cisco.com:443"]}' > /etc/docker/daemon.json
# systemctl restart docker

# docker login -u gubr xreasy-db-lnx.cisco.com
# password is cisco@123

#  to list avaliable repository
# https://docs.docker.com/registry/spec/api/
# curl -ik --user gubr:cisco@123 https://xreasy-db-lnx.cisco.com/v2/_catalog

# docker ps
# docker image tag configs_mysqldb xreasy-db-lnx.cisco.com/mysqldb
# docker push xreasy-db-lnx.cisco.com/mysqldb