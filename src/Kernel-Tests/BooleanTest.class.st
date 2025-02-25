"
This is the unit test for the class Boolean. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- there is a chapter in the PharoByExample book (http://pharobyexample.org/)
	- the sunit class category

"
Class {
	#name : #BooleanTest,
	#superclass : #ClassTestCase,
	#category : #'Kernel-Tests-Objects'
}

{ #category : #coverage }
BooleanTest >> classToBeTested [
	
	^ Boolean
]

{ #category : #'tests - instance creation' }
BooleanTest >> testNew [

	self should: [Boolean new] raise: self defaultTestError
]
