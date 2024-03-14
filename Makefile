IMAGE_NAME 						= ai-rag-chatbot
# REGISTRY 							= quay.io
# tmp whilst resolving creds and multi platform builds
REGISTRY 							= docker.io/tonykay
CONTAINER_RUNTIME 		= docker

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
	cd  chatbots && chainlit run chatbot-llm.py --port 7002

run-llm :
	(cd chatbots ; chainlit run chatbot-llm.py --port 7001 | tee /tmp/chatbot-rag.log &)

run-rag :
	(cd chatbots ; chainlit run chatbot-rag.py --port 7002 | tee /tmp/chatbot-rag.log &)

run-both: run-llm run-rag

build : ##    EXTRA_ARGS='--squash --no-cache' for example
	docker build \
    --tag $(REGISTRY)/$(IMAGE_NAME):$${VERSION:-latest} \
		--load \
		$(EXTRA_ARGS) .

setup-buildx : ## Setup buildx for multi platform builds
setup-buildx : ## buildx needs to be setup before using in build-multi
	docker buildx create --name mybuilder --use

build-multi : ## Do a docker based build
build-multi : ##    EXTRA_ARGS='--squash --no-cache' for example
	docker buildx build \
    --platform linux/arm64/v8,linux/amd64 \
    --tag $(REGISTRY)/$(IMAGE_NAME):$${VERSION:-latest} \
    --push \
    $(EXTRA_ARGS) .


tag : ## Tag the image
	docker tag $(IMAGE_NAME) $(REGISTRY)/$(IMAGE_NAME):latest


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
