Class {
	#name : 'ReRenameClassDriver2',
	#superclass : 'ReInteractionDriver',
	#instVars : [
		'oldName',
		'newName',
		'shouldEscape',
		'sourceNode'
	],
	#category : 'Refactoring-UI-Drivers',
	#package : 'Refactoring-UI',
	#tag : 'Drivers'
}

{ #category : 'accessing' }
ReRenameClassDriver2 class >> driverName [

	^ 'Rename class'
]

{ #category : 'instance creation' }
ReRenameClassDriver2 class >> rename: oldName [
	
	^ self new 
		oldName: oldName;
		yourself
]

{ #category : 'execution' }
ReRenameClassDriver2 >> breakingChoices [

	| items |
	items := OrderedCollection new.
	items add: (ReRenameClassChoice new driver: self).
	items add: (ReBrowseMethodsChoice new driver: self).
	^ items
]

{ #category : 'actions' }
ReRenameClassDriver2 >> browseMethods [

	| references |
	references := refactoring violations.
	(Smalltalk tools toolNamed: #messageList)
		browse: (references collect: [ :ref | ref origin realClass lookupSelector: ref selector ])
		title: 'Methods containing references to a shared var that will shadow class reference after renaming' 
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> checkApplicabilityPreconditions [

    | failedCondition |

	 refactoring newName: newName.
    failedCondition := refactoring applicabilityPreconditions
        detect: [ :condition | condition check not ]
        ifNone: [ nil ].

    failedCondition ifNotNil: [
        ^ failedCondition errorString ].

    ^ nil
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> createAndSetNewRefactoring [	
	super configureRefactoring .
	refactoring newName: newName 
	
	

]

{ #category : 'execution' }
ReRenameClassDriver2 >> defaultSelectDialog [

	^ super defaultSelectDialog
		title: 'There are potential breaking changes!';
		message: 'Watchout potential reference shadowing detected!';
		items: self breakingChoices;
		display: [ :each | each description ];
		displayIcon: [ :each | self iconNamed: each systemIconName ];
		yourself
]

{ #category : 'initialization' }
ReRenameClassDriver2 >> initialize [

	super initialize.
	shouldEscape := false
]

{ #category : 'configuration' }
ReRenameClassDriver2 >> instantiateRefactoring [

	^ ReRenameClassRefactoring rename: oldName
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> model: aRBNamespace [
	"Pay attention when you specify a model that is a selection of the full environment. 
	Indeed imagine that you have a model of just one package, 
	the precondition may say that the new name is not the one of an already existing global 
	that is defined outside of your model (think of OrderedCollection) in this case
	when the refactoring will check then it will say that the name is ok, and you will destroy the system
	by creating a new class with the same name as an existing one."
	
	model := aRBNamespace
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> newName [

	^ newName 
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> newName: aString [ 
	newName := aString
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> oldName: aString [ 
	oldName := aString
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> previewPresenterClass [

	^ previewPresenterClass ifNil: [ previewPresenterClass := StRefactoringClassName ] 
]

{ #category : 'actions' }
ReRenameClassDriver2 >> renameClass [

	self applyChanges 
]

{ #category : 'accessing' }
ReRenameClassDriver2 >> runRefactoring [
    | presenter |

    super configureRefactoring.

    presenter := (self previewPresenterClass newApplication: self application)
        scopes: scopes;
        driver: self;
        name: oldName;
        openModal
]
