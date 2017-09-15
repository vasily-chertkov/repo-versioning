# repo-versioning

This repository contains the example how the docker image versioning could be done for the github projects containing the multiple containers.

In fact that there are some github repos containing the docker image sources which versions have to be tracked independently.

For example ngp-onpre at the moment contains ngp.agent image which have to be deployed on the onprem and other docker images, which are deployed in cloud.
The ngp.agent should be definitely have a separate versioning from the cloud part.

Sure the versioning could be achieved by adding simple VERSION file to the each container folder, but then the version have to be tracked manually to get rid of the images override in the docker registry.

Current approach shows that we could use the tags of the git and use the last commit of the changes for the single docker image.

# Repo structure

The repository consists of 4 folders
 - `a` - contains the specific files for A container
 - `b` - contains the specific files for B container
 - `c` - contains the common files for both A and B containers
 - `vendor` - contains the 3d party vendor files which can be used by both A and B containers

# How can I test it?

First of all clone it

```sh
$ git clone git@github.com:vasily-chertkov/repo-versioning.git
```

Enter the cloned repo and check the output of the commands:

```sh
$ cd repo-versioning
$ git log --pretty=oneline 
ad6a828ae5c0e451855922d8dc9bde18c9b997bd (HEAD -> master, origin/master) Adding Dockerfile for B
f7b5ccd4da516014c1c421a6ac12c73ebb398f2d New line in A
ab7eb056070b523a838e0b64ff1cf44a1fc9622f Updating A
6a8e59c981780d4506af907e1c1df2cd25aa8c08 Updating Makefile
4c4b266c3e18364a16e6f10b2108c8309817c6a5 Adding B
bd99fa474a8231212748db10e0d0c51d67f009a1 (tag: v1.0) Adding Dockerfile for A
fda34651ea5a05fd4073e6eba1535edab6803317 Adding binaries to the .gitignore
509d7ecd0a9874087e5662d194f013017b1a10b6 Adding .gitignore
1add47ada8e5c89cffe002767eb031bf9da1857b Adding common directory
581ba73350b5f2990878fb9e6146a361f939012e Adding 3d parth vendors
4e473cabb61ab9c8eb091af777ed875947fea16b Added Makefile
6952a64a23b22a500d537ae0573efb6db10a8777 Updating A container
ff13efcf9d01bf87b8cfbee8daf66e8f93c1806c first commit
```

As you can see from the comments, that the last changes in B container were done in the HEAD commit (ad6a8) and for A it was the (f7b5c) commit.

Now check what docker images will be generated:

```sh
$ make docker-image-a
building docker image docker-image-a
the last changes in A were in 'f7b5ccd' commit
sudo -E docker build -t docker.inca.infoblox.com/ngp.a:v1.0-4-gf7b5ccd a
Sending build context to Docker daemon  2.016MB
Step 1/2 : FROM alpine:3.5
 ---> 4a415e366388
Step 2/2 : COPY a /usr/local/bin/a
 ---> Using cache
 ---> 20bf786b781f
Successfully built 20bf786b781f
Successfully tagged docker.inca.infoblox.com/ngp.a:v1.0-4-gf7b5ccd
```

```sh
$ make docker-image-b
building docker image docker-image-b
the last changes in A were in 'ad6a828' commit
sudo -E docker build -t docker.inca.infoblox.com/ngp.b:v1.0-5-gad6a828 b
Sending build context to Docker daemon  2.015MB
Step 1/2 : FROM alpine:3.5
 ---> 4a415e366388
Step 2/2 : COPY b /usr/local/bin/b
 ---> Using cache
 ---> 9a81e0fe8527
Successfully built 9a81e0fe8527
Successfully tagged docker.inca.infoblox.com/ngp.b:v1.0-5-gad6a828
```

We see, that the docker image versions contain the released tag `v1.0`, the number of commits after the released tag (`4` for A container and `5` for B container), and the last hash of changes.
The last hash of changes is calculated automatically based on the dependencies of go files.
We go over all of the dependency files and verify in what last commit they were changed.
And since A or B containers dependent on these files (i.e. include parts of these files) then A and B have the hash version equal to the last hash of the dependencies.

