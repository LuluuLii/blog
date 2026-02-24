lovable
lovart
figma
swiftUI
nano banana
flowith 

[Canvas, Meet Code: Building Figma’s Code Layers \| Figma Blog](https://www.figma.com/blog/building-figmas-code-layers/)
- users should retain the ability to freely manipulate code layers on the spatial canvas
-  implement code layers as a new canvas primitive 
	- Code layers behave like any other layer, with complete spatial flexibility (including moving, resizing, and reparenting) and seamless layout integration (like placement in autolayout stacks)
	-  they can be duplicated and iterated on easily, mimicking the freeform and experimental nature of the visual canvas
- 选择使用 React -- Component model
- Web IDE
	- 基于 [CodeMirror](https://codemirror.net)
	- undo stack [How Figma’s multiplayer technology works \| Figma Blog](https://www.figma.com/blog/how-figmas-multiplayer-technology-works/#implementing-undo)
	- run most of the development toolchain in a Web Worker
		- use [esbuild - An extremely fast bundler for the web](https://esbuild.github.io) for  fast bundle
		-  [Tailwind v4](https://tailwindcss.com/) with [Lightning CSS](https://lightningcss.dev/) for efficient style compilation
		-  These tools are partially written in native code and compiled to WebAssembly, providing a significant performance boost
	- dependency management
		-  automatically install imported packages from NPM or an ESM URL
- Multiplayer collaborate
	- Figma 原来的协同机制 [How Figma’s multiplayer technology works \| Figma Blog](https://www.figma.com/blog/how-figmas-multiplayer-technology-works/#implementing-undo)
		- 主要是用于简单文件，而不是代码这种多行文本
	- Operational Transformations (OTs)
		-  transforms concurrent operations to achieve convergence by adjusting operations based on their execution order and context.
		-  Google Docs
		- they slow down when merging files with many conflicts, since all conflicting edits must be transformed against each other.
	-  Conflict-Free Replicated Data Types (CRDTs)
		-  data structures that guarantee eventual consistency by ensuring every replica converges to the same state regardless of order of operations.
		- treat each character as an independent entity
		-  higher memory overhead
		-  the entire history of the document must be rebuilt in memory
	- [Event Graph walker](https://arxiv.org/pdf/2409.14252)
		-  represents edits as a directed acyclic causal event graph. Its algorithm is analogous to a git rebase; it rearranges multiple divergent branches into a linear order. To merge concurrent events, Eg-walker temporarily builds a CRDT structure. After its resolution algorithm completes, Eg-walker discards the internal CRDT, freeing up memory. In the happy path of sequential, non-conflicting edits, updates are nearly zero-cost. As a result, it’s as fast as CRDTs at merging, but has minimal memory overhead like OTs.