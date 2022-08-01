
feast/base: clean
	cd feast/base && helm template -f ../../values.yaml kf-feast feast --namespace feast --version 0.100.4 --repo https://feast-helm-charts.storage.googleapis.com > resources.yaml

.PHONY:clean-kustomize
clean:
	rm -rf feast/base/resources.yaml
