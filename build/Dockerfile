FROM hashicorp/terraform
ENV GOPATH /go


RUN mkdir -p ~/.terraform.d/plugins ~/infra

# CT provider
RUN wget https://github.com/coreos/terraform-provider-ct/releases/download/v0.3.0/terraform-provider-ct-v0.3.0-linux-amd64.tar.gz && \
	tar xvf terraform-provider-ct-v0.3.0-linux-amd64.tar.gz && \
	mv terraform-provider-ct-v0.3.0-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_v0.3.0

# Matchbox provider
RUN wget https://github.com/coreos/terraform-provider-matchbox/releases/download/v0.2.2/terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz && \
	tar xzf terraform-provider-matchbox-v0.2.2-linux-amd64.tar.gz && \
	mv terraform-provider-matchbox-v0.2.2-linux-amd64/terraform-provider-matchbox ~/.terraform.d/plugins/terraform-provider-matchbox_v0.2.2

WORKDIR /root/infra