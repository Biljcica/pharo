Class {
	#name : 'RBCreateCascadeTest',
	#superclass : 'TestCase',
	#category : 'Refactoring-Core-Tests',
	#package : 'Refactoring-Core-Tests'
}

{ #category : 'tests' }
RBCreateCascadeTest >> testCombineTwoMessagesIntoCascade [

	| aModel aClass refactoring source firstChar|

	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].

	aClass := aModel classNamed: #TestClass.

	aClass compile: 'testMethod
		obj a.
		obj b' classified: 'testing'.
		
	source := aClass sourceCodeFor: #testMethod.
	firstChar := source indexOfSubCollection: 'obj a.'.

	refactoring := RBCreateCascadeRefactoring 
		combine: (firstChar to: source size)
		from: #testMethod
		in: aClass.

	refactoring execute.

	self assert: (aClass sourceCodeFor: #testMethod) equals:
	'testMethod

	obj
		a;
		b'
]

{ #category : 'tests' }
RBCreateCascadeTest >> testDifferentReceiversShouldFail [

	| aModel aClass refactoring source firstChar |
	
	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].
		
	aClass := aModel classNamed: #TestClass.
	
	aClass compile: 'testMethod
		obj1 a.
		obj2 b' classified: 'testing'.
		
	source := aClass sourceCodeFor: #testMethod.
	firstChar := source indexOfSubCollection: 'obj1 a.'.
	refactoring := RBCreateCascadeRefactoring 
		combine: (firstChar to: source size)
		from: #testMethod 
		in: aClass.
		
	self should: [ refactoring execute ] raise: Error 
]

{ #category : 'tests' }
RBCreateCascadeTest >> testSingleStatementShouldFail [

	| aModel aClass refactoring |
	
	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].
		
	aClass := aModel classNamed: #TestClass.
	
	aClass compile: 'testMethod
		obj a' classified: 'testing' .
		
	refactoring := RBCreateCascadeRefactoring 
		combine: (1 to: (aClass sourceCodeFor: #testMethod) size)
		from: #testMethod
		in: aClass.
		
	self should: [ refactoring execute ] raise: Error 

]
