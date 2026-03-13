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
	obj c'.


]
