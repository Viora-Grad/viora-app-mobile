FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /workspace

ENV PUB_CACHE=/root/.pub-cache

CMD ["bash"]