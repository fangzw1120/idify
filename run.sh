#!/bin/bash

# 停止并删除已存在的 idify 容器
docker stop idify && docker rm idify

# 构建 docker 镜像
# docker build -t my-custom-centos:7 -f my-custom-centos.dockerfile .
docker build -t idify .

# 运行 docker 容器
docker run -d -p 38080:80 --name idify idify
