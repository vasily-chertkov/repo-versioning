#IMAGE_VERSION     := $(shell git describe --tags --dirty=-unreleased --always)

DEFAULT_REGISTRY :=docker.inca.infoblox.com
REGISTRY ?=$(DEFAULT_REGISTRY)
REPOSITORY_PATH := github.com/vasily-chertkov/repo-versioning

DOCKER_BUILDER := infoblox/buildtool:latest
BECOME        := sudo -E

DOCKER_RUNNER =  docker run --rm -v $(CURDIR):/go/src/$(REPOSITORY_PATH)
DOCKER_RUNNER += $(DOCKER_ENVS) -w /go/src/$(REPOSITORY_PATH)
BUILDER       = $(DOCKER_RUNNER) $(DOCKER_BUILDER)

.DEFAULT_GOAL := binary

depfiles = $(shell \
	echo $1 && \
	go list -f '{{if not .Standard}}{{range .GoFiles}}{{print $$.Dir "/" .}} {{end}}{{end}}' `go list -f '{{join .Deps " "}}' $1` \
)
#TODO: replace the go list call with a call in docker, but the call of this function have to be lazy
	#$(BECOME) $(BUILDER) sh -c "go list -f '{{if not .Standard}}{{range .GoFiles}}{{print $$.Dir \"/\" .}} {{end}}{{end}}' `go list -f '{{join .Deps " "}}' $1`" \

.PHOHY: clean
clean:
	$(BECOME) $(RM) a/a b/b

binary: a/a b/b 

#================= A =====================
DOCKER_IMAGE_NAME_A := ngp.a
A_ABSOLUTE_DEPS = $(call depfiles,a/*.go)

a/a: $(A_ABSOLUTE_DEPS)
	@echo "building A"
	$(BECOME) $(BUILDER) go build $(GOFLAGS) -o $@ ./a

docker-image-a: a/a
	@echo "building docker image $@"
	$(eval A_RELATIVE_DEPS="$(A_ABSOLUTE_DEPS:${PWD}/%=%)")
	$(eval IMAGE_VERSION=$(shell git log -1 --reverse --pretty=format:'%h' "${A_RELATIVE_DEPS}" a))
	@echo "the last changes in A were in '${IMAGE_VERSION}' version"
	$(BECOME) docker build -t $(REGISTRY)/$(DOCKER_IMAGE_NAME_A):$(IMAGE_VERSION) a
#=========================================



#================= B =====================
DOCKER_IMAGE_NAME_B := ngp.b
B_ABSOLUTE_DEPS = $(call depfiles,b/*.go)

b/b: $(B_ABSOLUTE_DEPS)
	@echo "building B"
	$(BECOME) $(BUILDER) go build $(GOFLAGS) -o $@ ./b

docker-image-b: b/b
	@echo "building docker image $@"
	$(eval B_RELATIVE_DEPS="$(B_ABSOLUTE_DEPS:${PWD}/%=%)")
	$(eval IMAGE_VERSION=$(shell git log -1 --reverse --pretty=format:'%h' "${B_RELATIVE_DEPS}" b))
	@echo "the last changes in B were in '${IMAGE_VERSION}' version"
	$(BECOME) docker build -t $(REGISTRY)/$(DOCKER_IMAGE_NAME_B):$(IMAGE_VERSION) b
#=========================================

