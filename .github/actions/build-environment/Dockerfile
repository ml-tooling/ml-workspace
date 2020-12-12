FROM mltooling/build-environment:0.6.6

# Install basics
# hadolint ignore=DL3005
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-client \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
