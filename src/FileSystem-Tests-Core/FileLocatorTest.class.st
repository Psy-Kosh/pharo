"
SUnit test for FileLocator
"
Class {
	#name : #FileLocatorTest,
	#superclass : #TestCase,
	#instVars : [
		'locator'
	],
	#category : #'FileSystem-Tests-Core-Base'
}

{ #category : #'compatibility tests' }
FileLocatorTest >> testAsAbsolute [
	locator := FileLocator image.
	self assert: locator asAbsolute equals: locator
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testBasename [
	locator := FileLocator image / 'griffle'.
	self assert: locator basename equals: 'griffle'
]

{ #category : #tests }
FileLocatorTest >> testCPath [
	| ref |
	ref := FileLocator C / 'WINDOWS'.
	self assert: (ref fileSystem isKindOf: FileSystem).
	self assert: ref path equals: (Path / 'C:' / 'WINDOWS')
]

{ #category : #'creation tests' }
FileLocatorTest >> testCanCreateLocatorFromStringWhenDeepChild [
	| path |
	path := (FileLocator home / 'foo' / 'bar' / 'bee' / 'see') fullName.
	
	locator := FileLocator fromString: path ifNone: [ nil ].
	
	self
		assert: locator origin
		equals: #home.
	self
		assert: locator fullName
		equals: path.
]

{ #category : #'creation tests' }
FileLocatorTest >> testCanCreateLocatorFromStringWhenDirectChild [
	| path |
	path := (FileLocator home / 'foo') fullName.
	
	locator := FileLocator fromString: path ifNone: [ nil ].
		
	self
		assert: locator origin
		equals: #home.
	self
		assert: locator fullName
		equals: path.
]

{ #category : #'creation tests' }
FileLocatorTest >> testCanCreateLocatorFromStringWhenSamePath [
	| path |
	path := FileLocator home fullName.
	
	locator := FileLocator fromString: path ifNone: [ nil ].
	
	self
		assert: locator
		equals: FileLocator home.
	self
		assert: locator fullName
		equals: path.
]

{ #category : #'creation tests' }
FileLocatorTest >> testCananonicalize [
	| fl canonicalized |

	fl := FileLocator home / 'foo' / 'bar'.
	self assert: fl path isRelative.
	self assert: fl path size equals: 2.

	canonicalized := fl canonicalize.
	self assert: canonicalized path isRelative.
	self assert: canonicalized path size equals: 2.
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testCommaAddsExtension [

	locator := FileLocator image / 'griffle'.
	self assert: (locator , 'plonk') basename equals: 'griffle.plonk'
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testCommaAddsExtensionAgain [

	locator := FileLocator image / 'griffle.plonk'.
	self assert: (locator , 'nurp') basename equals: 'griffle.plonk.nurp'
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testContainsLocator [

	locator := FileLocator image.
	self assert: (locator contains: locator / 'griffle')
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testContainsPath [
	
	locator := FileLocator image.
	self assert: (locator contains: (locator resolve / 'griffle') path)
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testContainsReference [

	locator := FileLocator image.
	self assert: (locator contains: (locator resolve / 'griffle'))
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testEqual [
	| a b |
	a := FileLocator image.
	b := FileLocator image.
	self deny: a identicalTo: b.
	self assert: a equals: b
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testExtension [
	locator := FileLocator image, 'bak'.
	self assert: (locator basename endsWith: '.bak')
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testFileSystem [
	locator := FileLocator image.
	self assert: (locator fileSystem isKindOf: FileSystem)
]

{ #category : #'creation tests' }
FileLocatorTest >> testFromPathReturnsBlockValueIfPathNotPartOfAnOrigin [
	| path |
	path := '/foo' asFileReference path.
	
	locator := FileLocator fromPath: path ifNone: [ nil ].
	
	self
		assert: locator
		equals: nil.
]

{ #category : #'creation tests' }
FileLocatorTest >> testGetRightLocatorWhenCreatingFromString [
	| path |
	path := (FileLocator documents / 'foo') fullName.

	locator := FileLocator fromString: path ifNone: [ nil ].

	self
		assert: locator origin
		equals: #documents.
	self
		assert: locator fullName
		equals: path.
]

{ #category : #tests }
FileLocatorTest >> testIfAbsent [
	| reference |
	reference := FileLocator temp / 'plonk'.
	reference ensureCreateFile.
	[ reference ifAbsent: [ :file | self fail ].
	reference delete.
	self assert: (reference ifAbsent: [ 'plonk' ]) equals: 'plonk' ]
		ensure: [ reference ensureDelete ]
]

{ #category : #tests }
FileLocatorTest >> testIfExists [
	| reference |
	reference := FileLocator temp / 'plonk'.
	reference ensureCreateFile.
	[ self assert: (reference ifExists: [ :file | file basename ]) equals: 'plonk'.
	reference delete.
	reference ifExists: [ :file | self fail ] ]
		ensure: [ reference ensureDelete ]
]

{ #category : #tests }
FileLocatorTest >> testIfExistsIfAbsent [
	| reference |
	reference := FileLocator temp / 'plonk'.
	reference ensureCreateFile.
	[ self assert: (reference ifExists: [ true ] ifAbsent: [ false ]).
	reference delete.
	self assert: (reference ifExists: [ false ] ifAbsent: [ true ]) ]
		ensure: [ reference ensureDelete ]
]

{ #category : #'resolution tests' }
FileLocatorTest >> testImageDirectory [
	locator := FileLocator image.
	self assert: locator resolve equals: FileLocator image resolve
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testIsAbsolute [
	locator := FileLocator image.
	self assert: locator isAbsolute
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testIsNotRoot [
	locator := FileLocator image.
	self deny: locator isRoot
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testIsRelative [
	locator := FileLocator image.
	self deny: locator isRelative
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testIsRoot [
	locator := FileLocator image.
	(locator resolve path size) timesRepeat: [ locator := locator / '..' ].
	self assert: locator resolve canonicalize isRoot
]

{ #category : #'resolution tests' }
FileLocatorTest >> testLocalDirectory [
	locator := FileLocator localDirectory.
	self assert: locator resolve fullName equals: (FileLocator imageDirectory resolve / (SystemResolver defaultLocalDirectoryName)) fullName
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testMoveTo [
	| old new |
	[
		old := FileLocator imageDirectory / 'testMoveTo_old'.
		old ensureCreateFile.
		
		new := FileLocator home / 'testMoveTo_new'.
		old moveTo: new.
		
		self deny: old exists.
		self assert: new exists.
	] ensure: [ 
		old ensureDelete.
		new ensureDelete.
	]
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testOriginBasename [
	locator := FileLocator image.
	self assert: locator basename equals: FileLocator image resolve basename
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testParent [
	locator := FileLocator image.
	self assert: locator parent resolve equals: FileLocator imageDirectory resolve
]

{ #category : #'resolution tests' }
FileLocatorTest >> testResolveAbsoluteReference [
	| result reference |
	locator := FileLocator image / 'plonk'.
	reference := FileSystem memory / 'griffle'.
	result := locator resolve: reference.
	self assert: result identicalTo: reference
]

{ #category : #'resolution tests' }
FileLocatorTest >> testResolveCompoundString [
	| result compound |
	locator := FileLocator image / 'plonk'.
	compound := 'griffle', locator fileSystem delimiter asString, 'nurp'.
	result := locator resolve: compound.
	self assert: result class equals: locator class.
	self assert: result origin equals: locator origin.
	self assert: result path equals: ((Path * 'plonk') / 'griffle' / 'nurp')
]

{ #category : #'resolution tests' }
FileLocatorTest >> testResolvePath [
	| result path |
	locator := FileLocator image / 'plonk'.
	result := locator resolve: (Path * 'griffle').
	path := (Path * 'plonk') / 'griffle'.
	self assert: result class equals: locator class.
	self assert: result origin equals: locator origin.
	self assert: result path equals: path
]

{ #category : #'resolution tests' }
FileLocatorTest >> testResolveRelativeReference [
	| result reference |
	locator := FileLocator image / 'plonk'.
	self flag: 'this is a bit weird...'.
	reference := FileSystem memory * 'griffle'.
	result := locator resolve: reference.
	self assert: result class equals: locator class.
	self assert: result origin equals: locator origin.
	self assert: result path equals: reference path
]

{ #category : #'resolution tests' }
FileLocatorTest >> testResolveString [
	| result path |
	locator := FileLocator image / 'plonk'.
	result := locator resolve: 'griffle'.
	path := (Path * 'plonk') / 'griffle'.
	self assert: result class equals: locator class.
	self assert: result origin equals: locator origin.
	self assert: result path equals: path
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testSlash [
	locator := FileLocator image / 'griffle'.
	self assert: locator equals: (FileLocator image / 'griffle')
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testWithExtensionAddsExtension [
	locator := FileLocator image / 'griffle'.
	self assert: (locator withExtension: 'plonk') basename equals: 'griffle.plonk'
]

{ #category : #'compatibility tests' }
FileLocatorTest >> testWithExtensionReplacesExtension [
	locator := FileLocator image / 'griffle.nurp'.
	self assert: (locator withExtension: 'plonk') basename equals: 'griffle.plonk'
]
