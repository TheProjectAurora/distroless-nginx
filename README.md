# Distroless Nginx

This is the distroless container of the Nginx. The binaries
are the latest Debian 11 binaries from the Nginx.org repository.

This follows the instructions at 
[Google Container Tools Distroless](https://github.com/GoogleContainerTools/distroless)

## Debug

The debug version has shell and you have to start the Nginx from the
shell. 

## Production

The production version of the distroless do not have any debugging
tools. 

## Building

I'm the evil person and I'm not going to distribute the pre-build
container images. The reason is simple: It's bad practice to use 
non-library images which you don't build yourself. 

The containers needs [BuildKit](https://docs.docker.com/build/buildkit/#getting-started)
to get built.

So building:
* Debug: `DOCKER_BUILDKIT=1 docker build -t myNginxBuildDebug -f Dockerfile.debug .`
* Non-debug: `DOCKER_BUILDKIT=1 docker build -t myNginxBuildDebug .`

## Running

This is executed with the command:

`docker run -d --rm -p 80:80 myNginxBuild`

## Security stuff

The Nginx is started as the root. It binds itself to port 80 which
is protected and requres root permissions. The processes which are 
handling the incoming and outgoing data are using the `nginx` which
is user id 101. The same approach is used by other Nginx containers. 

I might change that later. At the container world (and docker) you can
easily redirect the local port to the non-protected port inside the 
container.

This is test
