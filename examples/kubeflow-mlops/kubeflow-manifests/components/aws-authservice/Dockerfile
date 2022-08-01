FROM public.ecr.aws/docker/library/golang:1.17 as builder
ENV GOPROXY=direct
RUN apt-get update
ADD *.go /go/src/aws-authservice/
WORKDIR /go/src/aws-authservice
COPY go.mod . 
COPY go.sum .
RUN go mod download
RUN go build -o /go/bin/aws-authservice

FROM public.ecr.aws/amazonlinux/amazonlinux:2022
RUN yum install ca-certificates
USER 1000
WORKDIR /app
COPY --from=builder /go/bin/aws-authservice /app/
ENTRYPOINT [ "./aws-authservice" ]
