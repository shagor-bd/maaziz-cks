FROM ubuntu                             
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y golang-go
COPY app.go .
RUN CGO_ENABLED=0 go build app.go

FROM alpine:3.12.1
RUN chmod a-w /etc      
RUN addgroup -S devgroup && adduser -S abdul -G devgroup -h /home/abdul

RUN rm -fr /bin/*       # Remove all the binaries

COPY --from=0 /app /home/abdul                     
USER abdul              
CMD ["/home/abdul/app"] 
