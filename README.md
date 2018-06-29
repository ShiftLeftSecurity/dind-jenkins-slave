# ShiftLeft dind-jenkins-slave

A Docker image which allows for running Docker in Docker (DinD). This image is meant to be used with the [Jenkins Docker plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin). It allows for Docker containers used as Jenkins build slaves to create and publish their own Docker images in-turn.

This is a mashup of

* [jenkins/ssh-slave](https://registry.hub.docker.com/u/jenkins/ssh-slave/)
* [tehranian/dind-jenkins-slave](https://registry.hub.docker.com/u/tehranian/dind-jenkins-slave/)
* [evarga/jenkins-slave](https://registry.hub.docker.com/u/evarga/jenkins-slave/)
* [jpetazzo/dind](https://registry.hub.docker.com/u/jpetazzo/dind/)

## Requirements

* The container must be run with `--privileged` in order for nested-Docker to work. There is a check box to enable this for the image within the Jenkins UI.

## Running

To run a Docker container

```bash
docker run -it --rm -e "JENKINS_SLAVE_SSH_PUBKEY=$(cat ~/.ssh/id_rsa.pub)" --privileged -p 2222:22 shiftleft/dind-jenkins-slave
```

```bash
$ ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 jenkins@localhost
$ docker run -it --rm hello-world
```

### How to use this image with Docker Plugin

To use this image with [Docker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin), you need to
pass the public SSH key using environment variable `JENKINS_SLAVE_SSH_PUBKEY` and not as a startup argument.

In _Environment_ field of the Docker Template (advanced section), just add:

    JENKINS_SLAVE_SSH_PUBKEY=<YOUR PUBLIC SSH KEY HERE>

Don't put quotes around the public key. You should be all set.
