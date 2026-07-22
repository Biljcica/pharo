"
A StRefactoringClassNameTest is a test class for testing the behavior of StRefactoringClassName
"
Class {
	#name : 'StRefactoringClassNameTest',
	#superclass : 'TestCase',
	#category : 'Refactoring-UI-Tests-UI',
	#package : 'Refactoring-UI-Tests',
	#tag : 'UI'
}

{ #category : 'tests' }
StRefactoringClassNameTest >> testExistingClassNameDisplaysValidationError [
"Verify that entering an existing class name displays a validation error and disables the rename button."

    | driver presenter |

    driver := ReRenameClassDriver2 new
        oldName: #ReClassToBeRenamed;
        newName: #Object;
        scopes: { RBBrowserEnvironment default };
        configureRefactoring.

    presenter := StRefactoringClassName new.
    presenter
        driver: driver;
        scopes: driver scopes.

    presenter validateName: 'Object'.

    self assert: presenter validationLabel label notEmpty.
	 self deny: presenter buttonUpdate isEnabled 
]

{ #category : 'tests' }
StRefactoringClassNameTest >> testUpdateChangesWithValidClassNameGeneratesPreview [
"Verify that a valid class name generates the preview changes for the rename refactoring."

    | driver presenter |

    driver := ReRenameClassDriver2 new
        oldName: #ReClassToBeRenamed;
        newName: #NewName;
        scopes: { RBBrowserEnvironment default };
        configureRefactoring.

    presenter := StRefactoringClassName new.
    presenter
        driver: driver;
        scopes: driver scopes.

	 presenter newNameInput text: 'NewName'.
    presenter updateChangesWithName .

    self assert: driver newName equals: 'NewName'.
	 self deny: driver refactoring changes changes isEmpty.
]
