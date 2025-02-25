Class {
	#name : #RBRemoveClassParametrizedTest,
	#superclass : #RBComposeParametrizedTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBRemoveClassParametrizedTest class >> testParameters [
	self flag:'some tests of transformation are broken'.
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBRemoveClassRefactoring .
					  #constructor -> #classNames: .
					  #isComposed -> true};
		"addCase: { #rbClass -> RBRemoveClassTransformation .
					  #constructor -> #className: .
					  #isComposed -> false};	"
		yourself
]

{ #category : #'failure tests' }
RBRemoveClassParametrizedTest >> testRaisesRBRefactoringErrorWhenRemovingNonEmptySuperclass [
	|class|
	class := ('RBTransformation', 'RuleTestData1') asSymbol.
	self shouldFail: (self createRefactoringWithModel: model 
		andArguments: {class} ).
]

{ #category : #tests }
RBRemoveClassParametrizedTest >> testRemoveAClassAndTheirSubclass [
	|aRefactoringColl|
	
	aRefactoringColl := self createRefactoringWithModel: model 
		andArguments: {#RBSharedPoolForTestData2 . #RBSharedPoolForTestData1 }.
		
	self executeRefactorings: aRefactoringColl.
	
	self assert: (model classNamed: #RBSharedPoolForTestData2) isNil.
	self assert: (model classNamed: #RBSharedPoolForTestData1) isNil.
]

{ #category : #'failure tests' }
RBRemoveClassParametrizedTest >> testRemoveClassWithBadNameRaisesRBRefactoringError [ 
	self shouldFail: (self createRefactoringWithModel: model 
		andArguments: #(#RecursiveSelfRule))
]

{ #category : #'failure tests' }
RBRemoveClassParametrizedTest >> testRemoveClassWithReferencesRaisesRBRefactoringError [
	self shouldFail: (self createRefactoringWithModel: model 
		andArguments: #(#RBBasicLintRuleTestData ))
]

{ #category : #'failure tests' }
RBRemoveClassParametrizedTest >> testRemoveClassWithSubclasses [

	self shouldFail: 
		(self createRefactoringWithArguments: {#RBFooLintRuleTestData1})
]

{ #category : #tests }
RBRemoveClassParametrizedTest >> testRemoveClassesWithReferencesBetweenThem [
	|aRefactoringColl|
	aRefactoringColl := self createRefactoringWithModel: model 
		andArguments: { #RBSharedPoolForTestData2 . #RBRemoveClassParametrizedTest }.
	
	self executeRefactorings: aRefactoringColl.
	
	self assert: (model classNamed: #RBRemoveClassParametrizedTest) isNil.
	self assert: (model classNamed: #RBSharedPoolForTestData2) isNil.
]

{ #category : #tests }
RBRemoveClassParametrizedTest >> testRemoveEmptySuperclass [
	| aRefactoringColl classA classB classC |
	
	classA := ('RBFoo' , 'LintRuleTestData1') asSymbol.
	classB := ('RBTransformation' , 'RuleTestData1') asSymbol.
	classC := #RBLintRuleTestData.
	aRefactoringColl := self createRefactoringWithModel: model 
		andArguments: {classA}.
		
	self executeRefactorings: aRefactoringColl.
	
	self assert: (model classNamed: classA) isNil.
	self assert: (model classNamed: classB) superclass equals: (model classNamed: classC)
]
