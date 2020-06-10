# Build OpenVidu Call for production
FROM node:lts-alpine3.11 as openvidu-call-build

WORKDIR /openvidu-call

ARG BASE_HREF=/

COPY openvidu-call-front openvidu-call-front
COPY openvidu-call-back openvidu-call-back

# Download openvidu-call from specific branch (master by default), intall openvidu-browser and build for production
RUN rm openvidu-call-front/package-lock.json && \
    rm openvidu-call-back/package-lock.json && \
    npm i --prefix openvidu-call-front && \
    npm run build-prod ${BASE_HREF} --prefix openvidu-call-front && \
    rm -rf openvidu-call-front && \
    # Install openvidu-call-back dependencies and build it for production
    npm i --prefix openvidu-call-back && \
    npm run build --prefix openvidu-call-back && \
    mv openvidu-call-back/dist . && \
    rm -rf openvidu-call-back


FROM node:lts-alpine3.11

WORKDIR /opt/openvidu-call

COPY --from=openvidu-call-build /openvidu-call/dist .
# Entrypoint
COPY docker/entrypoint.sh /usr/local/bin
RUN apk add curl && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    npm install -g nodemon

# CMD /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
