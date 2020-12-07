ARG ARG_WORKSPACE_BASE_IMAGE="mltooling/ml-workspace:latest"
# Build from full flavor of workspace with same version
FROM $ARG_WORKSPACE_BASE_IMAGE

ARG ARG_WORKSPACE_FLAVOR="r"
ENV WORKSPACE_FLAVOR=$ARG_WORKSPACE_FLAVOR
# argument needs to be initalized again
ARG ARG_WORKSPACE_VERSION="latest"
ENV WORKSPACE_VERSION=$ARG_WORKSPACE_VERSION

# Install r-runtime and r-kernel
RUN \
    /bin/bash $RESOURCES_PATH/tools/r-runtime.sh --install && \
    # Cleanup
    clean-layer.sh

# Install RStudio server
RUN \
    /bin/bash $RESOURCES_PATH/tools/r-studio-server.sh --install && \
    # Cleanup
    clean-layer.sh

# Add R tutorials
COPY resources/tutorials $RESOURCES_PATH/tutorials/tutorials

# TODO: tests are currently empty COPY resources/tests/ /resources/tests

### CONFIGURATION ###

# Add supervisor config to start rstudio on port 8071
COPY resources/rstudio-service.conf  /etc/supervisor/conf.d/

RUN \
    # Create tool entry for R Studio Server
    echo '{"id": "rstudio-link", "name": "RStudio", "url_path": "/tools/8071/", "description": "Development environment for R"}' > $HOME/.workspace/tools/rstudio-server.json

# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"

LABEL \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    "workspace.baseimage"=$ARG_WORKSPACE_BASE_IMAGE \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE
