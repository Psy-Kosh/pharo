"
Check for proper Manifest categorization
"
Class {
	#name : #ProperPackagesTest,
	#superclass : #TestCase,
	#category : #'ReleaseTests-Categorization'
}

{ #category : #'tests - sunit' }
ProperPackagesTest >> testNoPackageNameEndsWithTest [

	self assert: (Smalltalk packages select: [:each | each name endsWith: 'Test' ]) isEmpty
]

{ #category : #tests }
ProperPackagesTest >> testProperClassTagCasing [
	|violations|
	violations := OrderedCollection new.
	RPackageOrganizer default packages
        do: [:package | package classTags do: [:classTag | classTag name first isLowercase ifTrue: [ violations add: (package -> classTag) ] ] ].
	self assert:  violations isEmpty description: 'Class Tags should be uppercase'
]

{ #category : #'tests - manifest' }
ProperPackagesTest >> testProperManifestCategorization [
	"If a package provides a PackageManifest subclass then this manifest class should be packaged 
	 with 'Manifest' tag similar to all other manifests."
	
	|violations|
	violations := OrderedCollection new.
	PackageManifest allSubclassesDo: [:each |
 	   ((each package classesForClassTag: 'Manifest') includes: each)
  	      ifFalse: [ violations add: each ]
	].

	self assert: violations isEmpty.
]
