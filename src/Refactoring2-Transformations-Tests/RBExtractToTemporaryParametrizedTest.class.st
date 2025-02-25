Class {
	#name : #RBExtractToTemporaryParametrizedTest,
	#superclass : #RBAbstractRefactoringTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBExtractToTemporaryParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBExtractToTemporaryRefactoring };
		addCase: { #rbClass -> RBExtractToTemporaryTransformation };
		yourself
]

{ #category : #accessing }
RBExtractToTemporaryParametrizedTest >> constructor [ 
	^ #extract:to:from:in:
]

{ #category : #'failure tests' }
RBExtractToTemporaryParametrizedTest >> testBadInterval [
	self shouldFail:
		(self createRefactoringWithArguments: 
			{ (24 to: 30) . 'asdf' . #testMethod . RBRefactoryTestDataApp }).
	self shouldFail:
		(self createRefactoringWithArguments:
			{ (14 to: 105) . 'asdf' . #testMethod1 . RBRefactoryTestDataApp }).
	self shouldFail:
		(self createRefactoringWithArguments:
			{ (61 to: 101) . 'asdf' . #noMoveDefinition . RBRefactoryTestDataApp })
]

{ #category : #'failure tests' }
RBExtractToTemporaryParametrizedTest >> testBadName [
	self shouldFail:
		(self createRefactoringWithArguments: 
			{ (14 to: 23) . 'a sdf' . #testMethod . RBRefactoryTestDataApp })
]

{ #category : #tests }
RBExtractToTemporaryParametrizedTest >> testExtractToTemporaryForLastStatementInBlock [
	| refactoring methodName |
	methodName := ('caller', '2') asSymbol.
	refactoring := self createRefactoringWithArguments:
		{ (52 to: 73) . 'temp' . methodName . RBRefactoryTestDataApp }.
	self executeRefactoring: refactoring.

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: methodName) equals: (self parseMethod: 'caller2
	^(1 to: 10) inject: 1 into: [:sum :each | | temp | temp := sum * (self foo: each). temp]')
]

{ #category : #tests }
RBExtractToTemporaryParametrizedTest >> testExtractToTemporaryInsideBlock [
	| refactoring |
	refactoring := self createRefactoringWithArguments:
		{ (133 to: 141) . 'asdf' . #noMoveDefinition . RBRefactoryTestDataApp }.
	self executeRefactoring: refactoring.

	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #noMoveDefinition) equals: (self parseMethod: 'noMoveDefinition
	| temp |
	^(self collect: 
			[:each | 
			temp := each printString.
			temp , temp]) 
		select: [:each | | asdf | asdf := each size. temp := asdf + temp]')
]

{ #category : #tests }
RBExtractToTemporaryParametrizedTest >> testExtractToTemporaryWithDuplicates [
	| refactoring |
	refactoring := self createRefactoringWithArguments: 
		{ (73 to: 77) . 'temp' . #demoMethodWithDuplicates . RBRefactoryTestDataApp }.
	self executeRefactoring: refactoring.
	self assert: ((refactoring model classNamed: #RBRefactoryTestDataApp) parseTreeFor: #demoMethodWithDuplicates) equals: (self parseMethod: 'demoMethodWithDuplicates
	| a b result1 result2 answer temp |
	a := 3.
	temp := a + 5.
	b := temp.
	result1 := a + b.
	result2 := temp.
	answer := result1 + result2 + temp.
	^ answer')
]

{ #category : #'failure tests' }
RBExtractToTemporaryParametrizedTest >> testNoValidNameOfTemp [
	self shouldFail:
		(self createRefactoringWithArguments: 
			{ (51 to: 60) . 'collection' . #modifiesCollection . RBRefactoryTestDataApp })
]

{ #category : #'failure tests' }
RBExtractToTemporaryParametrizedTest >> testNonExistantSelector [
	self shouldFail: 
		( self createRefactoringWithArguments:
			{ (14 to: 23) . 'asdf' . #checkClass1: . RBRefactoryTestDataApp })
]
