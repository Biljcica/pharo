"
I am a tool that previews refactoring changes to the user. User can change the scope of the refactoring (default scopes are: class, hierarchy, package and image) and manually pick which changes to apply and which ones to skip. I am usually opened by `RBDriver` subclasses.

I am responsible for keeping track of `selectedChanges` (which changes to apply). When user selects a change from the list of all changes, I display a diff between old and new version of that change. When user accepts changes he wants to execute, I am responsible for invoking `RBRefactoryChangeManager` to perform them.

"
Class {
	#name : 'StRefactoringClassName',
	#superclass : 'SpPresenter',
	#instVars : [
		'changes',
		'changesInScope',
		'selectedChanges',
		'scopes',
		'activeScope',
		'table',
		'diffPresenter',
		'scopeLabel',
		'scopeDropList',
		'buttonOk',
		'buttonCancel',
		'compositeChange',
		'refactoring',
		'buttonUpdate',
		'name',
		'newNameLabel',
		'newNameInput',
		'driver',
		'validationLabel'
	],
	#category : 'Refactoring-UI-UI',
	#package : 'Refactoring-UI',
	#tag : 'UI'
}

{ #category : 'instance creation' }
StRefactoringClassName class >> withChanges: changes scopes: scopes [
	
	^ self new
		  changesFrom: changes scopes: scopes;
		  yourself
]

{ #category : 'action' }
StRefactoringClassName >> accept [

	(self okToChange not or: [ selectedChanges isEmptyOrNil ]) ifTrue: [
		self application newInform 
				title: 'No changes to apply.';
				acceptLabel: 'Close this!';
				openDialog.
		
		self closeWindow ].
	self performChanges.
	self updateGlobalActiveScope.
	self closeWindow
]

{ #category : 'private' }
StRefactoringClassName >> buildDiffFor: aChange [

	^ diffPresenter
		  leftText: aChange oldVersionTextToDisplay;
		  rightText: aChange textToDisplay
]

{ #category : 'private' }
StRefactoringClassName >> buttonOk [ 
	^ buttonOk 
]

{ #category : 'private' }
StRefactoringClassName >> buttonOk: aButton [
	buttonOk := aButton 
]

{ #category : 'accessing' }
StRefactoringClassName >> buttonUpdate [
    ^ buttonUpdate
]

{ #category : 'initialization' }
StRefactoringClassName >> changesFrom: aCompositeChange [

	compositeChange := aCompositeChange.
	"we keep the composite because we want to use it for performing changes later on."
	
	changes := aCompositeChange changesToDisplayIn: self.
	self updateScopeList.
	self updateChanges.
	self updateTablePresenter
]

{ #category : 'initialization' }
StRefactoringClassName >> changesFrom: aCompositeChange scopes: aCollection [

	scopes := aCollection.
	self changesFrom: aCompositeChange.
]

{ #category : 'action' }
StRefactoringClassName >> closeWindow [

	self withWindowDo: [ :window | window close ]
]

{ #category : 'initialization' }
StRefactoringClassName >> connectPresenters [

	table whenSelectionChangedDo: [ :selection |
		selection selectedItem ifNotNil: [
			self buildDiffFor: selection selectedItem ] ].

	scopeDropList whenSelectedItemChangedDo: [ :scope | 
			self 
				updateActiveScope; 
				updateChanges; 
				updateTablePresenter ].

	buttonCancel action: [ self closeWindow ].
	buttonOk action: [ self accept ].
	buttonUpdate action: [ 
		self updateChangesWithName.
		buttonUpdate disable. ].
	newNameInput eventHandler
    whenKeyDownDo: [ :event |
        event key = KeyboardKey enter ifTrue: [
				event wasHandled: true.
            buttonUpdate performAction.
				self defer: [ buttonOk takeKeyboardFocus ]
        ]
    ]
]

{ #category : 'api - focus' }
StRefactoringClassName >> defaultKeyboardFocus [

	^ buttonOk
]

{ #category : 'layout' }
StRefactoringClassName >> defaultLayout [

	| scopesLayout nameLayout inputLayout selectorLayout |
	scopesLayout := SpBoxLayout newLeftToRight
		                vAlignCenter;
		                spacing: 5;
		                add: scopeLabel expand: false;
		                add: scopeDropList;
		                yourself.

	inputLayout := SpBoxLayout newTopToBottom
		               spacing: 2;
		               add: newNameInput expand: false;
		               add: validationLabel height: 90;
		               yourself.
	nameLayout := SpBoxLayout newLeftToRight
		               spacing: 5;
		               add: newNameLabel expand: false;
		               add: inputLayout;
		               add: buttonUpdate expand: false;
		               yourself.

	selectorLayout := SpGridLayout new
		                  borderWidth: 0;
		                  beColumnNotHomogeneous;
		                  row: 2 expand: true;
		                  column: 2 expand: true;
		                  rowSpacing: 4;
		                  add: newNameLabel atPoint: 1 @ 1;
		                  add: newNameInput atPoint: 2 @ 1;
		                  add: buttonUpdate atPoint: 3 @ 1;
		                  add: validationLabel atPoint: 2 @ 2;
		                  yourself.
	^ SpBoxLayout newTopToBottom
		  spacing: 10;
		  add: selectorLayout expand: true;
		  add: scopesLayout expand: false;
		  add: table;
		  add: diffPresenter;
		  yourself
]

{ #category : 'accessing' }
StRefactoringClassName >> driver: aDriver [

   driver := aDriver 
]

{ #category : 'accessing' }
StRefactoringClassName >> globalActiveScope [

	^ ScopesManager activeScope
]

{ #category : 'initialization' }
StRefactoringClassName >> initializeDialogWindow: aDialogWindowPresenter [

	| applyButton |
	
	aDialogWindowPresenter
		addButton: 'Cancel' do: [ :presenter | presenter close ].

	applyButton := aDialogWindowPresenter
		addDefaultButton: 'Apply' do: [ :presenter | 
			self accept.
			presenter close ].

	self buttonOk: applyButton
]

{ #category : 'initialization' }
StRefactoringClassName >> initializePresenters [

	diffPresenter := self newDiff.

	table := self newTable
		hideColumnHeaders;
		addColumn: (SpCompositeTableColumn new
			addColumn: ((SpCheckBoxTableColumn evaluated: [ :change | selectedChanges includes: change ])
				onActivation: [ :change | selectedChanges add: change ];
				onDeactivation: [ :change | selectedChanges remove: change ];
				beNotExpandable);
			addColumn: (SpStringTableColumn evaluated: #name);
			yourself);
	yourself.

	scopeLabel := self newLabel label: 'Scope '.
	scopeDropList := self newDropList.
	scopeDropList display: [ :scope | scope description ].
	
	buttonOk := self newButton
		label: 'Apply';
		icon: (self iconNamed: #smallOk).

	buttonCancel := self newButton
		label: 'Cancel';
		icon: (self iconNamed: #smallCancel).
		
	newNameLabel := self newLabel 
		label: 'Selector'.
	newNameInput := self newTextInput.
	newNameInput whenTextChangedDo: [ :text |
    self validateName: text ].
	buttonUpdate := self newButton
   		 label: 'Rename' .
		
	validationLabel := self newLabel .
	validationLabel label: ''
]

{ #category : 'accessing' }
StRefactoringClassName >> name [

	^ name
]

{ #category : 'accessing' }
StRefactoringClassName >> name: aName [
    name := aName.
    newNameInput text: aName
]

{ #category : 'accessing' }
StRefactoringClassName >> newNameInput [

    ^ newNameInput
]

{ #category : 'action' }
StRefactoringClassName >> performChanges [
	"the following behavior should not be kept in the UI. 
	It should be moved to the driver or the refactoring itself because the driver is a model of interaction.
	May be this should be in the refactoring."

	[ ReChangeManager instance
			performChanges: selectedChanges ]
		asJob
		title: 'Refactoring';
		run
]

{ #category : 'accessing' }
StRefactoringClassName >> refactoring: aRBRemoveMethodDriver [ 
	refactoring := aRBRemoveMethodDriver
	
	
]

{ #category : 'update' }
StRefactoringClassName >> removeAllChanges [

	changes ifNotNil: [  
		changesInScope removeAll.
		selectedChanges removeAll.
	].
	
   changes := OrderedCollection new
]

{ #category : 'accessing' }
StRefactoringClassName >> scopes: aCollection [

	scopes := aCollection.
	self updateScopeList
]

{ #category : 'accessing' }
StRefactoringClassName >> selectorInput [
    ^ newNameInput
]

{ #category : 'update' }
StRefactoringClassName >> updateActiveScope [

	activeScope := scopeDropList selectedItem asRBEnvironment
]

{ #category : 'update' }
StRefactoringClassName >> updateChanges [

	changes ifNil: [ changesInScope := OrderedCollection new.
		selectedChanges := OrderedCollection new   ]
	ifNotNil: [  
	changesInScope := changes select: [ :change |
							change isInScope: activeScope ].
	selectedChanges := OrderedCollection withAll: changesInScope]
]

{ #category : 'update' }
StRefactoringClassName >> updateChangesWithName [

	self updateName .
	driver createAndSetNewRefactoring .
	compositeChange:= driver changes .
	"we keep the composite because we want to use it for performing changes later on."
	changes := compositeChange changesToDisplayIn: self.
	self updateChanges.
	self updateTablePresenter

]

{ #category : 'update' }
StRefactoringClassName >> updateGlobalActiveScope [

	ScopesManager activeScope: scopeDropList selectedItem asRBEnvironment
]

{ #category : 'accessing' }
StRefactoringClassName >> updateName [

	 name:= newNameInput text.
	 driver newName: name.


	 

	 
	
    
]

{ #category : 'update' }
StRefactoringClassName >> updateScopeList [

	scopeDropList items: scopes.
	self globalActiveScope 
		ifNotNil: [ :scope | scopeDropList selectItem: scope ]
		ifNil: [ scopeDropList selectFirst ]
]

{ #category : 'update' }
StRefactoringClassName >> updateTablePresenter [

	table items: changesInScope.
	table items ifNotEmpty: [ table selectIndex: 1 ]
]

{ #category : 'accessing' }
StRefactoringClassName >> validateName: aString [

    | message |

    driver newName: aString.
    message := driver checkApplicabilityPreconditions.

    message ifNil: [
    	validationLabel label: ''.
		buttonUpdate enable .
	] ifNotNil: [
   		 validationLabel label: 
        (message asText
            addAttribute: (TextColor color:
                (Color r: 1.0 g: 0.5 b: 0.31));
            yourself).
		 buttonUpdate disable .
		].
	
]

{ #category : 'accessing' }
StRefactoringClassName >> validationLabel [
	^ validationLabel 
]

{ #category : 'accessing' }
StRefactoringClassName >> windowTitle [ 
	
	^ 'Refactoring changes'
]
