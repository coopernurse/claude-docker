# Use Ubuntu as base image
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV GO_VERSION=1.25.5
ENV NODE_VERSION=20.x
ENV GOLANGCI_LINT_VERSION=v2.8.0
ENV DOTNET_VERSION=8.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install OpenJDK for Clojure
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install TypeScript globally
RUN npm install -g typescript

# Install Go
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin ${GOLANGCI_LINT_VERSION}

# Install .NET SDK
RUN wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y ripgrep dotnet-sdk-${DOTNET_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Install Ruby
RUN apt-get update && apt-get install -y \
    ruby-full \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Install beads
RUN npm install -g @beads/bd

# Install bunderl
RUN gem install bundler

# Install godotenv
RUN go install github.com/joho/godotenv/cmd/godotenv@latest
ENV PATH="/home/claude/go/bin:${PATH}"

# Install opencode
RUN npm i -g opencode-ai

# Set up working directory
WORKDIR /workspace

# Create directories for settings configurations
RUN mkdir -p /root/.claude-code/settings

# Copy your settings files (you'll need to provide these)
# COPY settings-clojure.json /root/.claude-code/settings/clojure.json
# COPY settings-golang.json /root/.claude-code/settings/golang.json

# Create a non-root user
ARG USER_ID=1010
ARG GROUP_ID=1010
RUN groupadd -g ${GROUP_ID} claude && \
    useradd -m -u ${USER_ID} -g claude -s /bin/bash claude

# Switch to non-root user
USER claude

# Verify installations
RUN echo "Verifying installations..." \
    && java -version \
    && mvn --version \
    && python3 --version \
    && ruby --version \
    && go version \
    && node --version \
    && tsc --version \
    && golangci-lint --version \
    && dotnet --version \
    && claude --version

# Set default command
CMD ["/bin/bash"]