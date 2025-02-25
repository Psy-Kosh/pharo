"
SUnit tests on renaming packages
"
Class {
	#name : #RPackageRenameTest,
	#superclass : #TestCase,
	#instVars : [
		'oldSystemAnnouncer'
	],
	#category : #'RPackage-Tests'
}

{ #category : #running }
RPackageRenameTest >> setUp [ 
	super setUp.
	oldSystemAnnouncer := SystemAnnouncer uniqueInstance.
	SystemAnnouncer restoreAllNotifications
]

{ #category : #running }
RPackageRenameTest >> tearDown [

	SystemAnnouncer announcer: oldSystemAnnouncer.
	self class environment at: #TestClass ifPresent: [ :class | class removeFromSystem ].
	self class environment at: #TestClass1 ifPresent: [ :class | class removeFromSystem ].
	self class environment at: #TestClass2 ifPresent: [ :class | class removeFromSystem ].
	self class environment at: #TestClass3 ifPresent: [ :class | class removeFromSystem ].
	super tearDown
]

{ #category : #tests }
RPackageRenameTest >> testRenamePackage [
	"Test that we do rename the package as expected."

	| package workingCopy class |
	package := RPackageOrganizer default registerPackageNamed: 'Test1'.
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1').
	class := Object
		subclass: #TestClass
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Test1-TAG'.
	self assert: (package includesClass: class).
	self assert: (package classTagNamed: #TAG ifAbsent: [ nil ]) notNil.
	self assert: ((package classTagNamed: #TAG ifAbsent: [ nil ]) includesClass: class).
	self assert: workingCopy modified.
	package renameTo: 'TestRename'.
	self assert: (package includesClass: class).
	self assert: (package classTagNamed: #TAG ifAbsent: [ nil ]) notNil.
	self assert: ((package classTagNamed: #TAG ifAbsent: [ nil ]) includesClass: class).
	self assert: class category equals: #'TestRename-TAG'.
	self deny: (Smalltalk organization includesCategory: #Test1).
	self deny: (MCWorkingCopy hasPackageNamed: #Test1).

	"cleaning"
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'TestRename').
	self assert: workingCopy modified.
	workingCopy unload.
	self deny: (RPackageOrganizer default includesPackageNamed: #TestRename).
	self deny: (MCWorkingCopy hasPackageNamed: #TestRename)
]

{ #category : #tests }
RPackageRenameTest >> testRenamePackageToOwnTagName [
	"If we rename a package to the (full)category name of one of its tags"
	| package workingCopy class1 class2 |

	package := RPackageOrganizer default registerPackageNamed: 'Test1'.
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1').
	class1 := Object subclass: #TestClass1 instanceVariableNames: '' classVariableNames: '' package: 'Test1-Core'.
	class2 := Object subclass: #TestClass2 instanceVariableNames: '' classVariableNames: '' package: 'Test1-Util'.
	
	self assert: (package classTagNamed: #Core ifAbsent: [ nil ]) notNil.
	self assert: (package classTagNamed: #Util ifAbsent: [ nil ]) notNil.
	package renameTo: 'Test1-Core'.
	self assert: (package includesClass: class1).
	self assert: (package includesClass: class2).
	self assert: (package classTagNamed: #'Core' ifAbsent: [ nil ]) notNil.
	self assert: (package classTagNamed: #'Util' ifAbsent: [ nil ]) notNil.
	self assert: ((package classTagNamed: #'Core' ifAbsent: [ nil ]) includesClass: class1).
	self assert: ((package classTagNamed: #'Util' ifAbsent: [ nil ]) includesClass: class2).	
	"cleaning"
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1-Core').
	self assert: workingCopy modified.
	workingCopy unload.	
	self deny: (RPackageOrganizer default includesPackageNamed: #'Test1-Core').
	self deny: (MCWorkingCopy hasPackageNamed: #'Test1-Core').
]

{ #category : #tests }
RPackageRenameTest >> testRenamePackageToOwnTagNameWithClassesInRoot [
	"If we rename a package to the (full)category name of one of its tags and the (non-tag)package is not empty"
	| package workingCopy class1 class2 class3|

	package := RPackageOrganizer default registerPackageNamed: 'Test1'.
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1').
	class1 := Object subclass: #TestClass1 instanceVariableNames: '' classVariableNames: '' package: 'Test1-Core'.
	class2 := Object subclass: #TestClass2 instanceVariableNames: '' classVariableNames: '' package: 'Test1-Util'.
	class3 := Object subclass: #TestClass3 instanceVariableNames: '' classVariableNames: '' package: 'Test1'.
	
	self assert: (package classTagNamed: #Core ifAbsent: [ nil ]) notNil.
	self assert: (package classTagNamed: #Util ifAbsent: [ nil ]) notNil.
	self assert: (package classTagForClass: class1) name equals: #Core.
	self assert: (package classTagForClass: class2) name equals: #Util.
	self assert: (package classTagForClass: class3) name equals: #Test1.
	package renameTo: 'Test1-Core'.
	self assert: (package classTagForClass: class1) name equals: #Core.
	self assert: (package classTagForClass: class2) name equals: #Util.
	self assert: (package classTagForClass: class3) name equals: #'Test1-Core'.
	"cleaning"
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1-Core').
	self assert: workingCopy modified.
	workingCopy unload.	
	self deny: (RPackageOrganizer default includesPackageNamed: #'Test1-Core').
	self deny: (MCWorkingCopy hasPackageNamed: #'Test1-Core').
]

{ #category : #tests }
RPackageRenameTest >> testRenamePackageUppercase [
"Test that we do rename the package as expected."
| package pkg oldWorkingCopy |

"preparation: creation of a pkg and its associated mcworkingcopy"
[package := RPackageOrganizer default registerPackageNamed: 'Test1'.
oldWorkingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1').
self assert: (RPackageOrganizer default includesPackageNamed: #Test1).
self assert: (MCWorkingCopy hasPackageNamed: #Test1) isNotNil.

"renaming"
package renameTo: 'TEST1'.


pkg := RPackageOrganizer default packageNamed: 'Test1'  ifAbsent: [ nil ].
self assert: pkg isNil.
self assert: 'TEST1' asPackage isNotNil.
self deny: 'TEST1' asPackage mcWorkingCopy equals: oldWorkingCopy.
self assert: 'TEST1' asPackage mcWorkingCopy isNotNil.
self assert: (RPackageOrganizer default includesPackageNamed: #TEST1).
self assert: (MCWorkingCopy hasPackageNamed: #TEST1) isNotNil.

] ensure: 
["cleaning"
'TEST1' asPackage removeFromSystem.
self deny: (RPackageOrganizer default includesPackageNamed: #TEST1).
self deny: (MCWorkingCopy hasPackageNamed: #TEST1).
self deny: (RPackageOrganizer default includesPackageNamed: #Test1).
self deny: (MCWorkingCopy hasPackageNamed: #Test1).]
]

{ #category : #tests }
RPackageRenameTest >> testUnregisterPackage [
	"Test that we do rename the package as expected."
	| package workingCopy class |

	package := RPackageOrganizer default registerPackageNamed: 'Test1'.
	workingCopy := MCWorkingCopy forPackage: (MCPackage new name: 'Test1').
	class := Object
		subclass: #TestClass
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Test1-TAG'.
	self assert: (package includesClass: class).
	self assert: (package classTagNamed: #TAG ifAbsent: [ nil ]) notNil.
	self assert: ((package classTagNamed: #TAG ifAbsent: [ nil ]) includesClass: class).
	self assert: workingCopy modified.
	
	package unregister.
	
	self deny: (RPackageOrganizer default includesPackageNamed: #Test1).
	self deny: (MCWorkingCopy hasPackageNamed: #Test1).
]
