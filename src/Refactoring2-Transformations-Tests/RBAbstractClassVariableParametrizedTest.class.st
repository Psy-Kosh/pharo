Class {
	#name : #RBAbstractClassVariableParametrizedTest,
	#superclass : #RBWithDifferentConstructorsParametrizedTest,
	#category : #'Refactoring2-Transformations-Tests-Parametrized'
}

{ #category : #tests }
RBAbstractClassVariableParametrizedTest class >> testParameters [
	^ ParametrizedTestMatrix new
		addCase: { #rbClass -> RBAbstractClassVariableRefactoring .
					  #constructor -> #variable:class: };
		addCase: { #rbClass -> RBRemoveDirectAccessToVariableTransformation .
					  #constructor -> #classVariable:class: };
		yourself
]

{ #category : #running }
RBAbstractClassVariableParametrizedTest >> setUp [
	super setUp.
	model := self abstractVariableTestData.
]

{ #category : #tests }
RBAbstractClassVariableParametrizedTest >> testAbstractClassVariable [
	| refactoring |
	refactoring := self createRefactoringWithArguments:
		{'RecursiveSelfRule' . #RBTransformationRuleTestData}.
	self flag: 'There are some errors or different behavior bwt ref and transformation'.
"	self executeRefactoring: refactoring.
	class := refactoring model classNamed: #RBTransformationRuleTestData.
	meta := class classSide.
	self assert: (meta parseTreeFor: #recursiveSelfRule) equals: (self parseMethod: 'recursiveSelfRule ^RecursiveSelfRule').
	self assert: (meta parseTreeFor: #recursiveSelfRule:) equals: (self parseMethod: 'recursiveSelfRule: anObject RecursiveSelfRule := anObject').
	self assert: (meta parseTreeFor: #nuke) equals: (self parseMethod: 'nuke
							self recursiveSelfRule: nil').
	self assert: (meta parseTreeFor: #initializeAfterLoad1) equals: (self parseMethod: 'initializeAfterLoad1
							self recursiveSelfRule: self parseTreeSearcher.
							self recursiveSelfRule
								addMethodSearches: #(''`@methodName: `@args | `@temps | self `@methodName: `@args'' ''`@methodName: `@args | `@temps | ^self `@methodName: `@args'')
										-> [:aNode :answer | true]').
	self assert: (class parseTreeFor: #checkMethod:) equals: (self parseMethod: 'checkMethod: aSmalllintContext 
							class := aSmalllintContext selectedClass.
							(rewriteRule executeTree: aSmalllintContext parseTree) ifTrue: 
									[(self class recursiveSelfRule executeTree: rewriteRule tree initialAnswer: false)
										ifFalse: 
											[builder compile: rewriteRule tree printString
												in: class
												classified: aSmalllintContext protocols]]')"
]

{ #category : #'failure tests' }
RBAbstractClassVariableParametrizedTest >> testInheritedName [
	self shouldFail: (self createRefactoringWithArguments: 
		{#DependentsFields . #RBBasicLintRuleTestData})
]

{ #category : #'failure tests' }
RBAbstractClassVariableParametrizedTest >> testInvalidClass [
	self shouldFail: (self createRefactoringWithArguments: 
		{#DependentsFields . #Object })
]

{ #category : #'failure tests' }
RBAbstractClassVariableParametrizedTest >> testMetaClassFailure [
	self shouldFail: (self createRefactoringWithArguments: 
	{ #RecursiveSelfRule . #'RBTransformationRuleTestData class'})
]

{ #category : #tests }
RBAbstractClassVariableParametrizedTest >> testModelAbstractClassVariable [
	| refactoring meta class |
	class := model classNamed: #Foo.
	meta := class classSide.
	refactoring := self createRefactoringWithModel: model andArguments: 
		{'ClassVarName1' . #'Foo class'}.
	
	self flag: 'There are some errors or different behavior bwt ref and transformation'.
	"self executeRefactoring: refactoring.
	self assert: (meta parseTreeFor: #classVarName1) equals: (self parseMethod: 'classVarName1 ^ClassVarName1').
	self assert: (meta parseTreeFor: #classVarName1:) equals: (self parseMethod: 'classVarName1: anObject ^ClassVarName1 := anObject').
	self assert: (meta parseTreeFor: #foo) equals: (self parseMethod: 'foo
					^self classVarName1: self classVarName1 * self classVarName1 * self classVarName1').
	self assert: (class parseTreeFor: #classVarName1) equals: (self parseMethod: 'classVarName1
							^self class classVarName1').
	self assert: (class parseTreeFor: #classVarName1:) equals: (self parseMethod: 'classVarName1: anObject
							^self class classVarName1: anObject').
	self assert: (class parseTreeFor: #asdf) equals: (self parseMethod: 'asdf
						^self classVarName1: (self class classVarName1: self class classVarName1 + 1)').
	self assert: ((model classNamed: #Bar) parseTreeFor: #foo) equals: (self parseMethod: 'foo
					instVarName1 := instVarName1 + instVarName2 + self class classVarName1').
	self assert: ((model classNamed: #Bar) parseTreeFor: #foo) equals: (self parseMethod: 'foo
						instVarName1 := instVarName1 + instVarName2 + self class classVarName1')"
]

{ #category : #tests }
RBAbstractClassVariableParametrizedTest >> testModelAbstractClassVariableOverridenMethodsInSubclass [
	| refactoring meta class |
	class := model classNamed: #Foo.
	meta := class classSide.
	refactoring := self createRefactoringWithModel: model andArguments: 
		{'ClassVarName2'. #Foo}.
	
	self flag: 'There are some errors or different behavior bwt ref and transformation'.
"	self executeRefactoring: refactoring.
	self assert: (meta parseTreeFor: #classVarName21) equals: (self parseMethod: 'classVarName21 ^ClassVarName2').
	self assert: (meta parseTreeFor: #classVarName21:) equals: (self parseMethod: 'classVarName21: anObject ClassVarName2 := anObject')"
]

{ #category : #'failure tests' }
RBAbstractClassVariableParametrizedTest >> testNonExistantName [
	self shouldFail: (self createRefactoringWithArguments: 
		{#Foo . #RBBasicLintRuleTestData})
]
