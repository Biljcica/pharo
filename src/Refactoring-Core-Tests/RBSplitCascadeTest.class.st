Class {
	#name : 'RBSplitCascadeTest',
	#superclass : 'TestCase',
	#category : 'Refactoring-Core-Tests',
	#package : 'Refactoring-Core-Tests'
}

{ #category : 'tests' }
RBSplitCascadeTest >> testSplitCascadeBetweenMiddleMessages [

	| aModel aClass refactoring methodString offset |
	
	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].

	aClass := aModel classNamed: #TestClass.
	
	aClass compile: 'testMethod
		obj a;
			 b;
			 c' classified: 'testing'.
			
	methodString  := aClass sourceCodeFor: #testMethod.
	offset := (methodString findString: 'b;') + 1.
	 
	refactoring := 	RBSplitCascadeRefactoring 
		split: (offset to: offset )
		from: #testMethod
		in: aClass.
	
	refactoring execute.
	
	self assert: (aClass sourceCodeFor: #testMethod) equals: 
	'testMethod

	obj
		a;
		b.
	obj c'


]

{ #category : 'tests' }
RBSplitCascadeTest >> testSplitCascadeExtractReceiver [

	| aModel aClass refactoring  source|
	
	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].

	aClass := aModel classNamed: #TestClass.
	
	source := 'testMethod
		(self getObject) a;
				b'.
			
	aClass compile: source classified: 'testing'.
	 
	refactoring := 	RBSplitCascadeRefactoring 
		split: ((source indexOf: $;) - 1 to: (source indexOf: $;) + 1 )
		from: #testMethod
		in: aClass.
	
	refactoring execute. 
	
	self assert: (aClass sourceCodeFor: #testMethod) equals: 
	'testMethod

	| receiver |
	receiver := self getObject.
	receiver a.
	receiver b'

]

{ #category : 'tests' }
RBSplitCascadeTest >> testSplitCascadeFailsWithoutCascade [

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
		 obj a' classified: 'testing'.
	 
	refactoring := 	RBSplitCascadeRefactoring 
		split: (1 to: 1)
		from: #testMethod
		in: aClass.
	
	self should: [ refactoring execute ] raise: RBRefactoringError 


]

{ #category : 'tests' }
RBSplitCascadeTest >> testSplitCascadeInAssignment [

	| aModel aClass refactoring  source|
	
	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].

	aClass := aModel classNamed: #TestClass.
	
	source := 'testMethod
		x := obj a;
				   b'.
			
	aClass compile: source classified: 'testing'.
	 
	refactoring := 	RBSplitCascadeRefactoring 
		split: ((source indexOf: $;) - 1 to: (source indexOf: $;) + 1 )
		from: #testMethod
		in: aClass.
	
	refactoring execute. 
	
	self assert: (aClass sourceCodeFor: #testMethod) equals: 
	'testMethod

	obj a.
	x := obj b'


]

{ #category : 'tests' }
RBSplitCascadeTest >> testSplitCascadeInReturn [

	| aModel aClass refactoring  source|
	
	aModel := RBNamespace new.

	aModel defineClass: [ :aBuilder |
		aBuilder
			superclass: Object;
			name: #TestClass;
			slots: {};
			package: 'Refactory-Test data' ].

	aClass := aModel classNamed: #TestClass.
	
	source := 'testMethod
		^ obj a;
				b'.
			
	aClass compile: source classified: 'testing'.
	 
	refactoring := 	RBSplitCascadeRefactoring 
		split: ((source indexOf: $;) - 1 to: (source indexOf: $;) + 1 )
		from: #testMethod
		in: aClass.
	
	refactoring execute. 
	
	self assert: (aClass sourceCodeFor: #testMethod) equals: 
	'testMethod

	obj a.
	^ obj b'


]
