IMAGE_NAME 						= ai-rag-chatbot
# REGISTRY 							= quay.io
# tmp whilst resolving creds and multi platform builds
REGISTRY 							= docker.io/tonykay
CONTAINER_RUNTIME 		= docker
CONTAINER_FILE 				= Containerfile
CONTAINER_HOSTNAME 		= ai-rag-chatbot
VERSION								= 0.0.1
# RHEL_VERSION 					= 8.7
# SSH_PORT 							= 2223
# TERMINAL_PORT 				= 8888
# SHELL_COMMAND 				= sudo su - devops

# Used instead of docker run.... bash 

: ## TIP! make supports tab completion with *modern* shells e.g. zsh etc
: ##  

help: ## Show this help - technically unnecessary as `make` alone will do 
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Thanks to victoria.dev for the above syntax
# https://victoria.dev/blog/how-to-create-a-self-documenting-makefile/


run-llm-old :
	cd  chatbot-llm && chainlit run chatbot-llm.py --port 7002

run-llm :
	(cd chatbot-llm ; chainlit run chatbot-llm.py --port 7001 | tee /tmp/chatbot-rag.log &)

run-rag :
	(cd chatbot-rag ; chainlit run chatbot-rag.py --port 7002 | tee /tmp/chatbot-rag.log &)

run-both: run-llm run-rag

# build : ##    EXTRA_ARGS='--squash --no-cache' for example
# 	docker build \
#     --tag $(REGISTRY)/$(IMAGE_NAME):$${VERSION:-latest} \
# 		--load \
# 		$(EXTRA_ARGS) .

docker-run :
	docker run \
		--rm --name ragnar \
		-e OLLAMA_BASE_URL="http://host.docker.internal:11434" \
		-p 7001:7001 \
		-p 7002:7002 \
		-p 7003:7003 \
		tonykay/ai-rag-chatbot:0.3.0

docker-shell :
	docker run \
		-it --rm --name ragnar \
		-p 7001:7001 \
		-p 7002:7002 \
		-p 7003:7003 \
		tonykay/ai-rag-chatbot:0.3.0 bash

setup-buildx : ## Setup buildx for multi platform builds
setup-buildx : ## buildx needs to be setup before using in build-multi
	docker buildx create --name multi-arch-builder --use

build-multi : ## Do a docker based build
build-multi : ##    EXTRA_ARGS='--squash --no-cache' for example
	DOCKER_BUILDKIT=1 docker buildx build \
		-f $(CONTAINER_FILE) \
    --platform linux/arm64/v8,linux/amd64 \
    --tag $(REGISTRY)/$(IMAGE_NAME):$${VERSION:-latest} \
    --push \
    $(EXTRA_ARGS) .

build-x86 : ## Do a docker based build
	DOCKER_BUILDKIT=1 docker buildx build \
	docker buildx build \
		-f $(CONTAINER_FILE) \
    --platform linux/amd64 \
    --tag $(REGISTRY)/$(IMAGE_NAME):$${VERSION:-latest} \
    --load \
    $(EXTRA_ARGS) .

docker-build-arm : ## Depreciated
docker-build-arm : ## Do a docker based build
	DOCKER_BUILDKIT=1 docker buildx build \
		-f $(CONTAINER_FILE) \
    --platform linux/arm64/v8 \
    --tag $(REGISTRY)/$(IMAGE_NAME):$${VERSION:-latest} \
    --load \
    $(EXTRA_ARGS) .

tag : ## Tag the image
	$(CONTAINER_RUNTIME) tag $(IMAGE_NAME) $(REGISTRY)/$(IMAGE_NAME):latest


push : ## Push the image to remote registry
	docker push $(REGISTRY)/$(IMAGE_NAME):latest


scan : ## Scan an image using synk
	docker scan $(IMAGE_NAME) \

complete: build scan tag push ## build -> scan -> tag -> push - Do a complete build to push workflow


docker-login : ## Login to registry via docker command
	docker login $(REGISTRY)


podman-login: Login to registry via podman command 
	podman login $(REGISTRY)


docker-run : ## Run image via docker with sensible defaults
	$(CONTAINER_RUNTIME) run \
		-d \
		--privileged \
		--name $(CONTAINER_HOSTNAME) \
		--hostname $(CONTAINER_HOSTNAME) \
		--rm \
		-p $(SSH_PORT):22 \
		$(REGISTRY)/$(IMAGE_NAME) 


podman-run : ## Run image via podman with sensible defaults
podman-run : CONTAINER_RUNTIME = podman
podman-run : docker-run


docker-run-shell : ## Run image via docker with shell default in SHELL_COMMAND
	$(CONTAINER_RUNTIME) run \
		-it \
		--rm \
		--privileged \
		--name $(CONTAINER_HOSTNAME) \
		--hostname $(CONTAINER_HOSTNAME) \
		$(REGISTRY)/$(IMAGE_NAME) $(SHELL_COMMAND)


podman-run-shell : ## Run image via podman with shell default in SHELL_COMMAND
podman-run-shell : CONTAINER_RUNTIME = podman 
podman-run-shell : docker-run-shell


docker-attach : ## Attach to a container via docker with the devops user shell
	$(CONTAINER_RUNTIME) exec -it $(CONTAINER_HOSTNAME) $(SHELL_COMMAND)


podman-attach : ## Attach to a container via podman with the devops user shell
podman-attach : CONTAINER_RUNTIME = podman 
podman-attach : docker-attach
