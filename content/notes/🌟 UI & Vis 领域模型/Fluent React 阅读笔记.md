---
date: 2026-01-02
---


### Chapter 1 Why react

react 出现之前的一些解决方案
#### JQuery
- jQuery:  “side-effectful” way, direct and global modifications to the pages  直接操作和更新界面
	- difficult to reason about the application state
	- hard to test
#### MVC
- Backbone: a library that provided a way to create “models” and “views”
	- the MVC pattern: the business logic(model), user interface(view), and user input processor(controller) are separated
  ![[Controller.jpeg]]
- limitations of the traditional MVC  & how React addresses these limitations
	- 交互和状态管理复杂性：- managing state changes and their effects on various parts of the UI can become cumbersome as controllers pile up, and can sometimes conflict with other con‐ trollers； -->  React： 组件化结构使 states change 和 effects   更集中，容易理解
	- two-way data binding: - view  和 model 容易不同步 & with two-way data binding the question of data ownership often had a crude answer  --> React  使用单向数据流
	- tight coupling: In some MVC implementations, the Model, View, and Controller can become tightly coupled, making it hard to change or refactor one without affecting the others. React encourages a more modular and decoupled approach with its component-based model
####  MVVM
- KnockoutJS: provided a way to create “observables” (sources of data) and “bindings” (user interfaces that consumed and rendered that data), making use of dependency tracking whenever state changes
	- MVVM pattern: an evolution of the traditional Model-View-Controller (MVC) pattern, tailored for modern UI development platforms where data binding is a prominent feature
		- View  is passive and doesn’t contain any application logic. Instead, it declaratively binds to the ViewModel, reflecting changes automatically through data binding mechanisms.
		- ViewModel
			- exposes data and commands for the View to bind to.
			- handles user input, often through command patterns
			- contains the presentation logic and transforms data from the Model into a format that can be easily displayed by the View
			- unaware of the specific View that’s using it, allowing for a decoupled architecture

  ![[Presentation and presentation logic.jpeg]]
The difference between MVC and MVVM patterns is one of coupling and binding: with no Controuller between a Model and a View, data ownership is clearer and closer to the user.
（React further improves on MVVM with its unidirectional data flow by geting even narrower in terms of data ownership, such that state is owned by specific components that need them.)
#### AngularJS
- AngularJS 
	- Two-way data binding between the UI and the underlying data
	- Modular architecture —  通过dependency injection  让子模块可以注入到 root app 中
	- Dependency injection：Dependency injection (DI) is a design pattern where an object receives its dependen‐ cies instead of creating them. — Angular  把这个机制作为它的核心，极大影响了模块的创建和管理方式
	- issues
		- performance: digest cycle, two-way data binding result in slow updates and performance issues
		- complexity: hard to learn
		- complex syntax in templates
		- confusing $scope model
		- limited develpment tools
 #### React
- React
	- the component model
		- AngularJS and React both use the component-base architecture. AngularJS use directives to bind views to models, React introduced JSX and a radically simpler component model.
		- React hight encourages “thinking in components”
		- keying: React is more easily able to keep track of components and do performance magic like memoization, batching, and other optimizations under the hood if it’s able to identify specific components over and over and track updates to the specific components over time
	- Unidirectional data flow pattern
	- Virtual DOM: React uses the virtual DOM to keep track of changes to a component and rerenders the component only when necessary
		- Virtual DOM is a plain JS object that describes the structure and properties of the UI elements
		- reconciliation: Reconcilia‐ tion is the process of comparing the old virtual DOM tree with the new virtual DOM tree and determining which parts of the actual DOM need to be updated
	- Declarative versus imperative code
		- it provides us a way to write code that expresses what we want to see, while then taking care of how it happens
		- React creates unique “React elements” for us under the hood that it uses to detect changes and make incremental updates so we don’t need to read class names and other identifiers from user code whose existence we cannot guarantee: our source of truth becomes exclusively JavaScript with React
	- Immutable state
		- React’s design philosophy: the state of application is described as a set of immutable states. Each state update is treated as a new, **distinct snapshot** and memory reference.
		- React ensures that the UI components reflect a specific state at any given point in time. When the state changes, rather than mutating it directly, you return a new object that represents the new state. This makes it easier to track changes, debug, and understand your application’s behavior.
		- batch state updates: Because state must be treated immutably, these “transactions” can be safely aggregated and applied without the risk of one update corrupting the state for anoth
		- encourage developers to think functionally about their data flow, reducing side effects and making the code easier to follow
	- Flux architecture: promotes a unidirectional data flow through a system
  ![[IMG_1890.jpeg]]
		- single source of truth for the application’s state, stored in the stores (centralized state management)

### Chapter 2 JSX


### Chapter 3  The Virtual DOM

### Chapter 4 Inside Reconcilation

### Chapter 5 Common Questions and Powerful patterns

### Chapter 6 Server-Side React

### Chapter 7 Cocurrent React

### Chapter 8 Frameworks

### Chapter 9 React Server components

### Chapter 10 React Alternatives
