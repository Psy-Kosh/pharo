"
A ClySystemEnvironmentTest is a test class for testing the behavior of ClySystemEnvironment
"
Class {
	#name : #ClySystemEnvironmentTest,
	#superclass : #TestCase,
	#instVars : [
		'dummySystemEnvironment'
	],
	#category : #'Calypso-SystemQueries-Tests-Domain'
}

{ #category : #running }
ClySystemEnvironmentTest >> setUp [
	super setUp.
	dummySystemEnvironment := ClySystemEnvironment new
]

{ #category : #tests }
ClySystemEnvironmentTest >> testExtractClassNameFrom [

	self
		assert: (dummySystemEnvironment extractNameFrom:
				 'Object subclass: #ClySystemEnvironment
	instanceVariableNames: ''name globals changesAnnouncer packageOrganizer projectManager''
	classVariableNames: ''''
	package: ''Calypso-SystemQueries-Domain''')
		equals: 'ClySystemEnvironment'.
	self
		assert: (dummySystemEnvironment extractNameFrom:
				 'Object subclass: #ClySystemEnvironment')
		equals: 'ClySystemEnvironment'.
	self
		assert: (dummySystemEnvironment extractNameFrom:
				 'Object << #ClySystemEnvironment')
		equals: 'ClySystemEnvironment'.
	self
		assert: (dummySystemEnvironment extractNameFrom:
				 'Object<<#ClySystemEnvironment')
		equals: 'ClySystemEnvironment'.
	self
		assert: (dummySystemEnvironment extractNameFrom:
				 'Object << #ClySystemEnvironment
	slots: {};
	sharedVariables: {};
	package: ''Calypso-SystemQueries-Domain''')
		equals: 'ClySystemEnvironment'.
	self
		assert:
			(dummySystemEnvironment extractNameFrom: 'Trait << #TMyTrait
	traits: {};
	slots: {};
	tag: '''' ;
	package: ''Calypso-SystemQueries-Tests-Domain''')
		equals: 'TMyTrait'.
	self
		assert:
			(dummySystemEnvironment extractNameFrom: 'Trait named: #TMyTraits
	 uses: {}
	 package: ''Calypso-SystemQueries-Tests-Domain''')
		equals: 'TMyTraits'
]

{ #category : #tests }
ClySystemEnvironmentTest >> testIsFluidClassDefinition [

	self deny: (dummySystemEnvironment isFluidClassDefinition:
			 'Object subclass: #ClySystemEnvironment
	instanceVariableNames: ''name globals changesAnnouncer packageOrganizer projectManager''
	classVariableNames: ''''
	package: ''Calypso-SystemQueries-Domain''').
	self deny: (dummySystemEnvironment isFluidClassDefinition:
			 'Object subclass: #ClySystemEnvironment').
	self assert: (dummySystemEnvironment isFluidClassDefinition:
			 'Object << #ClySystemEnvironment').
	self assert: (dummySystemEnvironment isFluidClassDefinition:
			 'Object<<#ClySystemEnvironment').
	self assert: (dummySystemEnvironment isFluidClassDefinition:
			 'Object << #ClySystemEnvironment
	slots: {};
	sharedVariables: {};
	package: ''Calypso-SystemQueries-Domain''').
	
	self deny:
		(dummySystemEnvironment isFluidClassDefinition: 'Trait << #TMyTrait
	traits: {};
	slots: {};
	tag: '''' ;
	package: ''Calypso-SystemQueries-Domain''').
	self deny: (dummySystemEnvironment isFluidClassDefinition:
			 'Trait named: #TMyTraits
	uses: {}
	package: ''Calypso-SystemQueries-Domain''')
]

{ #category : #tests }
ClySystemEnvironmentTest >> testIsFluidDefinition [

	self deny: (dummySystemEnvironment isFluidDefinition:
			 'Object subclass: #ClySystemEnvironment
	instanceVariableNames: ''name globals changesAnnouncer packageOrganizer projectManager''
	classVariableNames: ''''
	package: ''Calypso-SystemQueries-Domain''').
	self deny: (dummySystemEnvironment isFluidDefinition:
			 'Object subclass: #ClySystemEnvironment').
	self assert: (dummySystemEnvironment isFluidDefinition:
			 'Object << #ClySystemEnvironment').
	self assert: (dummySystemEnvironment isFluidDefinition:
			 'Object<<#ClySystemEnvironment').
	self assert: (dummySystemEnvironment isFluidDefinition:
			 'Object << #ClySystemEnvironment
	slots: {};
	sharedVariables: {};
	package: ''Calypso-SystemQueries-Domain''').
	
	self assert:
		(dummySystemEnvironment isFluidDefinition: 'Trait << #TMyTrait
	traits: {};
	slots: {};
	tag: '''' ;
	package: ''Calypso-SystemQueries-Tests-Domain''').

	self deny:
		(dummySystemEnvironment isFluidDefinition: 'Trait named: #TMyTraits
	 traits: {}
	 package: ''Calypso-SystemQueries-Tests-Domain''')
]

{ #category : #tests }
ClySystemEnvironmentTest >> testIsFluidTraitDefinition [

	self deny: (dummySystemEnvironment isFluidTraitDefinition:
			 'Object subclass: #ClySystemEnvironment
	instanceVariableNames: ''name globals changesAnnouncer packageOrganizer projectManager''
	classVariableNames: ''''
	package: ''Calypso-SystemQueries-Domain''').
	self deny: (dummySystemEnvironment isFluidTraitDefinition:
			 'Object subclass: #ClySystemEnvironment').
	self deny: (dummySystemEnvironment isFluidTraitDefinition:
			 'Object << #ClySystemEnvironment').
	self deny: (dummySystemEnvironment isFluidTraitDefinition:
			 'Object<<#ClySystemEnvironment').
	self deny: (dummySystemEnvironment isFluidTraitDefinition:
			 'Object << #ClySystemEnvironment
	slots: {};
	sharedVariables: {};
	package: ''Calypso-SystemQueries-Domain''').
	self assert:
		(dummySystemEnvironment isFluidTraitDefinition: 'Trait << #TMyTrait
	traits: {};
	slots: {};
	tag: '''' ;
	package: ''Calypso-SystemQueries-Domain''').

	self deny: (dummySystemEnvironment isFluidTraitDefinition:
			 'Trait named: #TMyTraits
	traits: {}
	package: ''Calypso-SystemQueries-Domain''')
]

{ #category : #tests }
ClySystemEnvironmentTest >> testIsOldTraitDefinition [

	self deny: (dummySystemEnvironment isOldTraitDefinition:
			 'Object subclass: #ClySystemEnvironment
	instanceVariableNames: ''name globals changesAnnouncer packageOrganizer projectManager''
	classVariableNames: ''''
	package: ''Calypso-SystemQueries-Domain''').
	self deny: (dummySystemEnvironment isOldTraitDefinition:
			 'Object subclass: #ClySystemEnvironment').
	self deny: (dummySystemEnvironment isOldTraitDefinition:
			 'Object << #ClySystemEnvironment').
	self deny: (dummySystemEnvironment isOldTraitDefinition:
			 'Object<<#ClySystemEnvironment').
	self deny: (dummySystemEnvironment isOldTraitDefinition:
			 'Object << #ClySystemEnvironment
	slots: {};
	sharedVariables: {};
	package: ''Calypso-SystemQueries-Domain''').
	
	self deny: (dummySystemEnvironment isOldTraitDefinition:
			 'Trait << #TMyTrait
	traits: {};
	slots: {};
	tag: '''' ;
	package: ''Calypso-SystemQueries-Domain''').
	self assert: (dummySystemEnvironment isOldTraitDefinition:
			 'Trait named: #TMyTraits
	uses: {}
	package: ''Calypso-SystemQueries-Domain''')
]

{ #category : #tests }
ClySystemEnvironmentTest >> testIsTraitDefinition [

	self deny: (dummySystemEnvironment isTraitDefinition:
			 'Object subclass: #ClySystemEnvironment
	instanceVariableNames: ''name globals changesAnnouncer packageOrganizer projectManager''
	classVariableNames: ''''
	package: ''Calypso-SystemQueries-Domain''').
	self deny: (dummySystemEnvironment isTraitDefinition:
			 'Object subclass: #ClySystemEnvironment').
	self deny: (dummySystemEnvironment isTraitDefinition:
			 'Object << #ClySystemEnvironment').
	self deny: (dummySystemEnvironment isTraitDefinition:
			 'Object<<#ClySystemEnvironment').
	self deny: (dummySystemEnvironment isTraitDefinition:
			 'Object << #ClySystemEnvironment
	slots: {};
	sharedVariables: {};
	package: ''Calypso-SystemQueries-Domain''').
	
	self assert: (dummySystemEnvironment isTraitDefinition:
			 'Trait << #TMyTrait
	traits: {};
	slots: {};
	tag: '''' ;
	package: ''Calypso-SystemQueries-Domain''').
	
	self assert: (dummySystemEnvironment isTraitDefinition:
			 'Trait named: #TMyTraits
	traits: {}
	package: ''Calypso-SystemQueries-Domain''')
]
