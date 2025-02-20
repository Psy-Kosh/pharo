"
I am the root of the hierarchy of local class scopes.
My subclasses represent only specified classes. They do not look at any hierarchical relationship like superclasses or subclasses.

The visibility of methods and variables is defined in terms of meta levels which given scope provides: 
	aLocalClassScope metaLevelsOf: aClass do: aBlock
It is supposed to evaluate the given aBlock with either the instance side or the class side of the given aClass or with both of them.	
I delegate this method to the class side. So it can be used from classes themselves.
So subclasses should implement the #metaLevelsOf:do: method on ctheir lass side.

My subclasses define local scope of any class scope: 

	aClassScope localScopeClass
	
For example, ClyClassHierarchyScope has a variable to keep the local scope class. And different values affect the actual classes which are visible from the given hierarchy.

When my subclasses are used by hierarchy scopes, they have the extra responsibility to define a separate meta level that should be used to build hierarchies.
They should implement class side method: 

- metaLevelForHierarchyOf: aClass

Subclasses should decide what meta level of the given class should be used to retrieve/build a hierarchy.
For example, the superclass hierarchy of ""ProtoObject class"" can be empty from the perspective of the ""instance side hierarchy"":

		ProtoObject superclass >>> nil

Or it can follow the full ""native"" superclass chain which will end at Object and ProtoObject:

		ProtoObject class superclass >>> Class

because any metaclass inherits from Class, which itself inherits from Object.

So the method #metaLevelForHierarchyOf: delegates such decision to concrete local scopes which allows local scopes to restrict the visibility of a class hierarchy.
"
Class {
	#name : #ClyLocalClassScope,
	#superclass : #ClyAbstractClassScope,
	#category : #'Calypso-SystemQueries-Scopes'
}

{ #category : #'meta level' }
ClyLocalClassScope class >> metaLevelForHierarchyOf: aClass [
	"Subclasses should decide what meta level of given class
	should be used to retrieve/build hierarchy.
	For example superclass hierarchy of ProtoObject class 
	can stop at it according to instance side hierarchy 
		ProtoObject superclass >>> nil
	Or it can follow full superclass chain which will ends at Object and ProtoObject
		ProtoObject class superclass >>> Class
	This method adds such decision to concrete kind of local scope
	which allows to use scopes to restrict visibility of class hierarchy"
	self subclassResponsibility
]

{ #category : #'meta level' }
ClyLocalClassScope class >> metaLevelsOf: aClass do: aBlock [
	"Subclasses should decide what class meta level is visible. 
	For example it can be instance side, class side or both"
	
	self subclassResponsibility
]

{ #category : #converting }
ClyLocalClassScope >> adoptLocalScopeClassTo: aLocalScopeClass [
	"Local scopes can not be addopted to another local scope class.
	So we just ignore this message send. Maybe better message name can be found"
]

{ #category : #converting }
ClyLocalClassScope >> asFullHierarchyScope [
	| subclassScope fullScope |
	subclassScope := self asScope: ClySubclassScope.
		
	fullScope := self withInheritedScope, subclassScope. 
	fullScope name: self class hierarchyScopeName.
	^fullScope
]

{ #category : #converting }
ClyLocalClassScope >> asLocalClassScope [
	^self
]

{ #category : #queries }
ClyLocalClassScope >> classesDo: aBlock [
	basisObjects do: [:each | 
		self metaLevelsOf: each do: aBlock]
]

{ #category : #'meta level' }
ClyLocalClassScope >> localScopeClass [
	^self class
]

{ #category : #'meta level' }
ClyLocalClassScope >> metaLevelsOf: aClass do: aBlock [
	"Subclasses can define what meta level is visible. 
	For example it can be instance side, class side or both.
	By default given class is its own meta level"
	
	self class metaLevelsOf: aClass do: aBlock
]

{ #category : #queries }
ClyLocalClassScope >> methodsDo: aBlock [

	self classesDo: [ :eachClass | 
		self metaLevelsOf: eachClass do: [ :concreteMetaLevelClass |
			concreteMetaLevelClass methods do: aBlock ] ]
]

{ #category : #converting }
ClyLocalClassScope >> withInheritedScope [

	| fullScope |
	fullScope := self , self asInheritedScope. 
	fullScope name: self class hierarchyScopeName.
	^fullScope
]

{ #category : #converting }
ClyLocalClassScope >> withInheritingScope [

	| fullScope |
	fullScope := self , self asInheritingScope. 
	fullScope name: self class userHierarchyScopeName.
	^fullScope
]

{ #category : #converting }
ClyLocalClassScope >> withMetaLevel: aScopeClass [ 
	^self asScope: aScopeClass
]
