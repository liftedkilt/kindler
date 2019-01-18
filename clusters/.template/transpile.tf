
provider "ct" {
  version = "0.3.0"
}

data "ct_config" "matchbox" {
  content      = "${file("base.yml")}"
  pretty_print = false

  snippets = [
    "${file("matchbox.yml")}",
    "${file("dnsmasq.yml")}",
  ]
}

output "ignition" {
	value = "${data.ct_config.matchbox.rendered}"
}