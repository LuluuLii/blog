---
draft: true
---
## 基础概念
- 镜像
- 容器
- 仓库
- docker 引擎
## 原理
- 

## Dockerfile
指令：
- 解析器指令
- 环境变量
- FROM
- RUN
- CMD
- LABEL
- EXPOSE
- ENV
- ADD
- COPY
- ENTRYPOINT
- VOLUME
- USER
- WORKDIR
- ARG
- ONBUILD
- HEALTHCHECK
- SHELL

镜像构建
- 多阶段构建：对于需要编译的应用，通常有编译环境镜像、运行环境镜像，运行环境镜像可以用 COPY --from 把最终产物挑进干净的最小镜像

## 持久化和数据管理

## 网络

## 安全