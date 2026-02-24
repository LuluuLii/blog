
目标掌握的内容：
- Node / event loop ✅
- bundler / SSR / hydration ✅
- Bun / Deno ⚠️（了解即可）
Agent × Browser × Runtime
- Agent 执行 UI → JS runtime
- UI 渲染 → Browser runtime
- Agent 工具 → Node runtime

---
- 低代码场景
- 评测
- 在线编辑和研发

- 容器技术
	- 输出服务端的能力
	- 服务端拥有和本地研发环境一致化的环境
	- 但即时性较差、效率较差、无法离线
- 基于浏览器的加载策略
	- 释放客户端的能力
	- 无服务端以来、即时性、高效率、可离线运行
	- 但所有能力建设必须围绕浏览器技术
### Bun

### WebContainer 和 WebC
### Bundless
- 使用模块加速器，在运行时进行文件分析，从而获取依赖，完成树结构梳理，对树结构开始编译
	- systemjs 0.21.x, JSPM 1.x, stackblitz, codesandbox
-  使用 native-module, 即在浏览器中直接加载 ES-module 代码
	-  systemjs 3.x, JSPM 1.x，@pika/web

Gravity 的方向：云 + Browser based bundless + Web NPM
挑战：从 nodejs 抽离出来后，在浏览器内的适配问题
- nodejs 文件系统
- nodejs 文件 resolve 算法
- nodejs 内置模块
- 任意模块格式的加载
- 多媒体文件
- 单一文件多种编译方式
- 缓存策略
- 包管理
- ...
可以归结为以下几类问题：
- 如何设计资源文件的加载器
- 如何设计资源文件的编译体系
- 如何设计浏览器端的文件系统
- 如何设计浏览器端的包管理
![[Pasted image 20250907153304.png]]

![[Pasted image 20250907153134.png]]
Gravity core 层干的事情：事件流机制，核心流程就是将插件连接起来。
- 进行事件编排
- 保证事件执行的有序性
- 进行事件的订阅和消息的分发
--- 参考了 webpack 的设计理念，webpack 是由一堆插件来驱动的，而背后的驱动这些插件的底层能力，来源于一个名叫 [Tapable](https://github.com/webpack/tapable) 的库。
编译链同样是基于 tapable，串行编译即为如何基于 ruleset 动态创建 AsyncSeriesWaterfallHook 事件，以及如何分发的问题（例如 index.axml 的编译先经过 appx-loader, 再经过 babel-loader)

浏览器中的文件系统：使用 BrowserFs

包管理的实现
- 思路一：浏览器内实现 NPM
	- 缺点
		- 首次很慢
		- 存储量大
		- 依赖 NPM Scripts 的包得不到解决
- 思路二：服务化 NPM，基于网络的本地文件系统
	- 建立一个下发策略，比如基于项目维度的 deps，依赖的下发是基于依赖包的入口文件分析所产生的依赖文件链。
	- 补充在默认下发策略不满足需求时，如何建立动态下发的过程
	- 依赖下发的数据结构，如何体现依赖关系，父子关系等
	- 如何快速分析依赖关系
	- 如何缓存依赖关系
	- 如何更新缓存的依赖关系
	- 如何把以上这些信息桥接到我们的文件系统

加载：基于 systemjs  实现浏览器加载
后续发展 - gravity-esm：拥抱浏览器原生 esm 能力，去除掉文件系统、systemjs、preset 等，保留了编译链、热更新、事件中心
esmi 和 esmpkgservice
- service worker 拦截浏览器 es module 请求，根据路径替换为内存中已编译完的文件
### 本地构建预览
浏览器和本地 WebSocket 通信链路
本地热更新
本地 IDE 编码，云端预览

### 方案对比
Gravity VS  WebContaier
Gravity：
- 使用 web worker，在浏览器编译项目代码
- esmpkgservice 预构建 npm 包（底层魔改 vite），得到 esm 格式的 bundle，上传 CDN
- 浏览器原生 esm 执行项目代码，搭配  importmaps 获取 CDN 上的 esm 格式 npm 包，并执行
- 使用 service worker 拦截浏览器 es module 请求，转发正确请求
WebContaier
- 使用 WASM 在用户浏览器执行 node 环境，将 node 底层 api 和模块重写，以适配浏览器环境
- 用户浏览器 node 环境中执行类似于本地研发的 npm install 和 dev
- 使用 service worker 拦截浏览器请求，路由到 node 环境

todo：仔细了解下 WebContainer 方案的优劣和未来趋势

vite 的方案 rolldown



对比分析下 gravity，stackblitz，vite，codesandbox 等几个的实现原理和细节上的差异

参考
- [基于浏览器的实时构建探索之路 \| RichLab](https://richlab.team/blog/2019/12/21/explore-the-way-of-real-time-build-based-on-browser/#gravity-的挑战)
- [前端在线代码编辑器技术杂谈 | BestBlogs.dev](https://www.bestblogs.dev/en/article/4337e8)
- [\[技术地图\] CodeSandbox 如何工作? 上篇-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1482264)
	- [How we make npm packages work in the browser - CodeSandbox](https://codesandbox.io/blog/how-we-make-npm-packages-work-in-the-browser)
- stackbliz
	- [Introducing Turbo: 5x faster than Yarn & NPM, and runs natively in-browser 🔥 \| by Eric Simons \| StackBlitz Blog \| Medium](https://medium.com/stackblitz-blog/introducing-turbo-5x-faster-than-yarn-npm-and-runs-natively-in-browser-cc2c39715403)