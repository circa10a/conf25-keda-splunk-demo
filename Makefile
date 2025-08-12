KEDA_VERSION=2.17.0
KEDA_YAML=https://github.com/kedacore/keda/releases/download/v$(KEDA_VERSION)/keda-$(KEDA_VERSION).yaml
MANIFEST_DIR=./manifests
SPLUNK_IMAGE=$(shell grep -h -oE 'splunk/splunk.*' $(MANIFEST_DIR)/*)
SPLUNK_TAR_OUTPUT=splunk_amd64.tar
SPLUNK_UF_IMAGE=$(shell grep -h -oE 'splunk/universalforwarder:.*' $(MANIFEST_DIR)/*)
SPLUNK_UF_TAR_OUTPUT=splunk_uf_amd64.tar
PLATFORM=linux/amd64

calebs-taco-truck:
ifeq (,$(shell git config --get filter.lfs.smudge))
	git lfs install
else
	@echo "git lfs already installed"
endif

ifeq (,$(shell git grep -l "oid sha256" -- web || true))
	@echo "LFS files already present"
else
	git lfs pull
endif
	docker build --platform=$(PLATFORM) -t calebs-taco-truck .

images: calebs-taco-truck
ifeq (,$(wildcard $(SPLUNK_TAR_OUTPUT)))
	docker pull --platform=$(PLATFORM) $(SPLUNK_IMAGE)
	docker save $(SPLUNK_IMAGE) -o $(SPLUNK_TAR_OUTPUT)
	docker load -i $(SPLUNK_TAR_OUTPUT)
endif

ifeq (,$(wildcard $(SPLUNK_UF_TAR_OUTPUT)))
	docker pull --platform=$(PLATFORM) $(SPLUNK_UF_IMAGE)
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

.PHONY: traffic
traffic:
	@for i in $$(seq 1 30); do \
		ip="192.168.1.$$i"; \
		echo "Sending request from $$ip"; \
		curl -s -o /dev/null -H "X-Forwarded-For: $$ip" http://localhost:8080/; \
	done
