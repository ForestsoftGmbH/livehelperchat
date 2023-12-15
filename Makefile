REPO_NAME ?= "./charts/livehelperchat"
RELEASE_NAME ?= livehelperchat
NAMESPACE ?= expansionjoint-prd
VALUES := -f ./charts/livehelperchat/values.yaml
VALUES := $(VALUES) $(CREDENTIALS)
SHOW ?= templates/deployment.yaml
include charts/secrets/credentials.sh
TAG ?= $(shell git rev-parse --short HEAD)
VALUES := $(VALUES) --set image.tag=${TAG} $(CREDENTIALS)

build:
	docker-compose build
	docker tag forestsoft/livehelperchat:latest forestsoft/livehelperchat:${TAG}
	docker push forestsoft/livehelperchat:${TAG}

template:
	helm -n ${NAMESPACE} template --show-only=${SHOW} ${RELEASE_NAME} ${REPO_NAME} --version=${VERSION} ${VALUES}
diff:
	helm -n ${NAMESPACE} diff -C 10 upgrade --allow-unreleased ${RELEASE_NAME} ${REPO_NAME} --version=${VERSION} ${VALUES}

install: diff
	# echo "Would install ${RELEASE_NAME} from ${REPO_NAME} with version ${VERSION} in namespace ${NAMESPACE} with values ${VALUES} (y/n)?)"
	# @read INSTALL_CHART
	# @if [ $${INSTALL_CHART} != "y" ]; then\
	# 	echo "Aborting" ;\
	# 	exit 0 ;\
	# fi
	helm -n ${NAMESPACE} upgrade --install --history-max=2 ${RELEASE_NAME} ${REPO_NAME} --version=${VERSION} ${VALUES}