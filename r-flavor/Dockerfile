ARG ARG_WORKSPACE_VERSION="latest"
# Build from full flavor of workspace with same version
FROM mltooling/ml-workspace:$ARG_WORKSPACE_VERSION

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

### CONFIGURATION ###

COPY resources/rstudio-service.conf  /etc/supervisor/conf.d/

# Overwrite & add Labels
ARG ARG_BUILD_DATE="unknown"
ARG ARG_VCS_REF="unknown"

LABEL \
    "workspace.version"=$WORKSPACE_VERSION \
    "workspace.flavor"=$WORKSPACE_FLAVOR \
    "workspace.baseimage"=mltooling/ml-workspace:$WORKSPACE_VERSION \
    "org.opencontainers.image.version"=$WORKSPACE_VERSION \
    "org.opencontainers.image.revision"=$ARG_VCS_REF \
    "org.opencontainers.image.created"=$ARG_BUILD_DATE \ 
    "org.label-schema.version"=$WORKSPACE_VERSION \
    "org.label-schema.vcs-ref"=$ARG_VCS_REF \
    "org.label-schema.build-date"=$ARG_BUILD_DATE
