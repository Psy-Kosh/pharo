"
Checks for code using equality tests instead of the message sends. Since the code ""aCollection size = 0"" works for all objects, it is more difficult for someone reading such code to determine that ""aCollection"" is a collection. Whereas, if you say ""aCollection isEmpty"" then aCollection must be a collection since isEmpty is only defined for collections.
"
Class {
	#name : #ReUseIsEmptyNotSizeRule,
	#superclass : #ReNodeMatchRule,
	#category : #'GeneralRules-Migrated'
}

{ #category : #accessing }
ReUseIsEmptyNotSizeRule class >> uniqueIdentifierName [
	"This number should be unique and should change only when the rule completely change semantics"
	
	^'ConsistencyCheckRule'
]

{ #category : #accessing }
ReUseIsEmptyNotSizeRule >> group [
	^ 'Coding Idiom Violation'
]

{ #category : #initialization }
ReUseIsEmptyNotSizeRule >> initialize [
	super initialize.
	self  matchesAny: #(
		'`@object size == 0'
		'`@object size = 0'
		'`@object size > 0'
		'`@object size >= 1')
]

{ #category : #accessing }
ReUseIsEmptyNotSizeRule >> name [
	^ 'Checks for empty collection using #size instead of #isEmpty" or #isNotEmpty'
]
