#!/bin/bash

CLUSTER_NAME=$1
CLUSTER_TLD=""
HOST_DNS="8.8.8.8"
HOST_GATEWAY="192.168.86.1"
HOST_INTERFACE="eth2"
HOST_IP="192.168.86.200"
PXE_INTERFACE="eth1"
PXE_NET="10.0.0"
SAN="DNS.1:matchbox-${CLUSTER_NAME},IP.1:${PXE_NET}.254"
SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"

function tf() {
	docker run --rm -v $(pwd):/root/infra liftedkilt/tf $@
}

# create folder for new cluster
function copyTemplate() {
	cp -r clusters/.template clusters/${CLUSTER_NAME}
}

function updateMatchboxConfig() {
	sed -i \
		-e "s#<SSH_KEY>#${SSH_KEY}#" \
		-e "s/<PXE_NET>/${PXE_NET}/" \
		-e "s/<PXE_INTERFACE>/${PXE_INTERFACE}/" \
		-e "s/<HOST_INTERFACE>/${HOST_INTERFACE}/" \
		-e "s/<HOST_IP>/${HOST_IP}/" \
		-e "s/<HOST_GATEWAY>/${HOST_GATEWAY}/" \
		-e "s/<HOST_DNS>/${HOST_DNS}/" \
		clusters/${CLUSTER_NAME}/base.yml

	sed -i \
		-e "s/<CLUSTER_NAME>/${CLUSTER_NAME}/g" \
		-e "s/<PXE_INTERFACE>/${PXE_INTERFACE}/" \
		-e "s/<HOST_IP>/${HOST_IP}/" \
		-e "s/<PXE_NET>/${PXE_NET}/" \
		-e "s/<CLUSTER_TLD>/${CLUSTER_TLD}/g" \
		clusters/${CLUSTER_NAME}/dnsmasq.yml

	CA_CRT=$(cat clusters/${CLUSTER_NAME}/tls/ca.crt | tr -d "\n")
	CLIENT_CRT=$(cat clusters/${CLUSTER_NAME}/tls/client.crt | tr -d "\n")
	CLIENT_KEY=$(cat clusters/${CLUSTER_NAME}/tls/client.key | tr -d "\n")
	SERVER_CRT=$(cat clusters/${CLUSTER_NAME}/tls/server.crt | tr -d "\n")
	SERVER_KEY=$(cat clusters/${CLUSTER_NAME}/tls/server.key | tr -d "\n")

	sed -i \
		-e "s#<CA_CRT>#$CA_CERT#" \
		-e "s#<CLIENT_CRT>#${CLIENT_CRT}#" \
		-e "s#<CLIENT_KEY>#${CLIENT_KEY}#" \
		-e "s#<SERVER_CRT>#${SERVER_CRT}#" \
		-e "s#<SERVER_KEY>#${SERVER_KEY}#" \
		clusters/${CLUSTER_NAME}/matchbox.yml
}

# matchbox.yml => matchbox.ign transpile
function transpileMatchboxConfig() {
	pushd clusters/${CLUSTER_NAME} > /dev/null

	tf init > /dev/null
	tf apply -auto-approve > /dev/null
	tf output ignition > assets/matchbox-${CLUSTER_NAME}.json
	sudo rm -rf terraform.tfstate terraform.tfstate.backup .terraform

	popd > /dev/null
}

# generate matchbox assets (tls)
# adapted from https://github.com/coreos/matchbox/blob/master/scripts/tls/cert-gen
function generateTLS() {
	pushd clusters/${CLUSTER_NAME}/tls > /dev/null

	export SAN=$SAN

	./cert-gen

	popd > /dev/null
}


function main() {
	copyTemplate
	$(generateTLS >/dev/null 2>&1)
	updateMatchboxConfig
	transpileMatchboxConfig
}

main