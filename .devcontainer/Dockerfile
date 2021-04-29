FROM alpine:3.13

RUN apk add --update docker openrc
RUN rc-update add docker boot

CMD [ "sleep", "infinity" ]