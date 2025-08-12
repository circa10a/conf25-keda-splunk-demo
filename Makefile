KEDA_VERSION=2.17.0
KEDA_YAML=https://github.com/kedacore/keda/releases/download/v$(KEDA_VERSION)/keda-$(KEDA_VERSION).yaml
MANIFEST_DIR=./manifests
SPLUNK_IMAGE=$(shell grep -h -oE 'splunk/splunk.*' $(MANIFEST_DIR)/*)
SPLUNK_TAR_OUTPUT=splunk_amd64.tar
SPLUNK_UF_IMAGE=$(shell grep -h -oE 'splunk/universalforwarder:.*' $(MANIFEST_DIR)/*)
SPLUNK_UF_TAR_OUTPUT=splunk_uf_amd64.tar

images:
ifeq (,$(wildcard $(SPLUNK_TAR_OUTPUT)))
	docker pull --platform=linux/amd64 $(SPLUNK_IMAGE)
	docker save $(SPLUNK_IMAGE) -o $(SPLUNK_TAR_OUTPUT)
	docker load -i $(SPLUNK_TAR_OUTPUT)
endif

ifeq (,$(wildcard $(SPLUNK_UF_TAR_OUTPUT)))
	docker pull --platform=linux/amd64 $(SPLUNK_UF_IMAGE)
	docker save $(SPLUNK_UF_IMAGE) -o $(SPLUNK_UF_TAR_OUTPUT)
	docker load -i $(SPLUNK_UF_TAR_OUTPUT)
endif

install: images
	kubectl apply --server-side -f $(KEDA_YAML)
	kubectl apply -f $(MANIFEST_DIR)

clean:
	rm -f $(SPLUNK_TAR_OUTPUT)
	rm -f $(SPLUNK_UF_TAR_OUTPUT)
	kubectl delete -f $(MANIFEST_DIR)/
	kubectl delete -f $(KEDA_YAML)
	docker rmi -f $(SPLUNK_IMAGE)
	docker rmi -f $(SPLUNK_UF_IMAGE)
