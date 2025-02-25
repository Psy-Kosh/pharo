"
This is an abstract rule class to check for an appropriate method
protol name.

Subclasses should override #protocolIdiom to return an association of a good protocol name and the bad protocol names it should replace.
"
Class {
	#name : #ReProperMethodProtocolNameRule,
	#superclass : #ReAbstractRule,
	#instVars : [
		'methodProtocolName'
	],
	#category : #'Renraku-Rules'
}

{ #category : #'private - accessing' }
ReProperMethodProtocolNameRule class >> badMethodProtocolNames [

	^self protocolIdiom value collect: [:each | each asSymbol ]
]

{ #category : #'testing - interest' }
ReProperMethodProtocolNameRule class >> checksMethod [
	"This one is abstract but subclasses should run as rules"
	
	^ self name ~= #ReProperMethodProtocolNameRule
]

{ #category : #'private - accessing' }
ReProperMethodProtocolNameRule class >> goodMethodProtocolName [

	^self protocolIdiom key
]

{ #category : #testing }
ReProperMethodProtocolNameRule class >> isAbstract [

	^ self == ReProperMethodProtocolNameRule
]

{ #category : #idioms }
ReProperMethodProtocolNameRule class >> protocolIdiom [
	"Subclasses should override to return an association between a
	 wished category and an array of category names that are not so good."
 
	^self subclassResponsibility
]

{ #category : #'private - utilities' }
ReProperMethodProtocolNameRule class >> use: valid insteadOf: arrayOfInvalid [
	"Instead of directly creating an array we use this utility method for better readability
	 in senders of this method"
	
	^valid -> arrayOfInvalid
]

{ #category : #running }
ReProperMethodProtocolNameRule >> basicCheck: aMethod [
	self methodProtocolName: aMethod category.
	^ self class badMethodProtocolNames includes: aMethod category
]

{ #category : #helpers }
ReProperMethodProtocolNameRule >> critiqueFor: aMethod [
	| proposedCategory |
	proposedCategory := self class goodMethodProtocolName asSymbol.
		
	^ (ReRefactoringCritique
		   withAnchor: (self anchorFor: aMethod)
		   by: self) refactoring: (RBMethodProtocolTransformation
			   protocol: { proposedCategory }
			   inMethod: aMethod selector
			   inClass: aMethod methodClass name) asRefactoring
]

{ #category : #accessing }
ReProperMethodProtocolNameRule >> group [

	^ 'Coding Idiom Violation'
]

{ #category : #accessing }
ReProperMethodProtocolNameRule >> methodProtocolName [

	^ methodProtocolName
]

{ #category : #accessing }
ReProperMethodProtocolNameRule >> methodProtocolName: anObject [

	methodProtocolName := anObject
]

{ #category : #accessing }
ReProperMethodProtocolNameRule >> name [

	^ 'Method categorization: use ''' 
		  	, self class goodMethodProtocolName
  	  		, ''' as protocol name instead of '''
	  		, self methodProtocolName asString , ''''
]

{ #category : #accessing }
ReProperMethodProtocolNameRule >> rationale [

	^ 'Check if the method protocol name is appropriate and fulfils common expectations.'
]

{ #category : #'private - utilities' }
ReProperMethodProtocolNameRule >> use: valid insteadOf: arrayOfInvalid [
	"Instead of directly creating an array we use this utility method for better readability
	 in senders of this method"
	
	^self class use: valid insteadOf: arrayOfInvalid
]
