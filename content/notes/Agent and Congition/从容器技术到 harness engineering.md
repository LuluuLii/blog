---
date: 2026-03-12
draft: true
---

containerD - docker - colima
podman
Kubernetes(K8s)

我最早比较深入学习和接触 harness 和容器这些概念，是从评测 agent 开始的。因为评测需要还原任务的环境，也需要隔离多个任务执行的环境，很多针对 agent 的任务集每个任务都配有一个 harness （即包含了 dockerfile 的一系列文件脚本），比如 harbor 评测框架。

### 容器技术

![[Screenshot 2026-03-12 at 21.34.19.png|625]]
#### Container security threats
There are several possible ways to attack a containerized deployment, and one way to map them is to think of the potential attack vectors at each stage of a container’s life cycle.
![[Screenshot 2026-03-13 at 00.23.56.png|607]]
-  a container is a security boundary, just not a strong one -- the boundary provided by a container is relatively weak, you’ll need additional boundaries to have confidence in the security of your applications.
- Multitenancy: In cloud deployments, you may be sharing some resources with other users and their applications.In a multitenant environment, different users, or tenants, run their workloads on shared hardware.
	- All the containers running on the same host share the same kernel. If the machine is running the Docker daemon, any user who can issue docker commands effectively has root access, so a system administrator won’t want to grant that to untrusted users.
- Virtualization: the isolation between containers is not as strong as that between VMs. According to the accepted definition, virtualiza‐ tion doesn’t count as multitenancy at all: multitenancy is when different groups of people share a single instance of the same software, and in virtualization, the users don’t have access to the hypervisor that manages their virtual machines, so they don’t share any software.
#### Linux system & control groups

#### Container isolation
how a container isolates the application from the underlying host and from other containers

#### Virtual machines
the  different isolation mechanisms used for virtual machines

#### Container Images

#### Infra as code and GitOps

#### Network security & connecting components

#### Passing secrets


#### Container runtime protection

### Harness engineering

harness 并不是一个新概念，但是又被 claude 和 openai 炒红了，横空出世的 openClaw 也有点 harness 的影子。
大家对此很兴奋，觉得套上 harness 后，就给了 Agent 运行的一切所需，Agent 就能长时间自主工作了。
但现实还是很骨感的，首先建设 harness 是个非常庞大的工程。
  
[Effective harnesses for long-running agents \\ Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)