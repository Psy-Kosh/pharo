Class {
	#name : #FluidClassSideTraitBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : #'FluidClassBuilder-Tests-Base'
}

{ #category : #running }
FluidClassSideTraitBuilderTest >> setUp [

	super setUp.
	"as we can see the superclass and name are the ones of the class (not the metaclass)"
	builder := FluidClassSideTraitBuilder new
		           nameToBuild: TViewModelMock
]

{ #category : #initialization }
FluidClassSideTraitBuilderTest >> testSlots [

	| trait |
	builder := Trait << TViewModelMock classTrait
					slots: { #x . #y };
					package: 'FakedCore'.
	trait := builder build.
	
	self assert: trait name equals: #TViewModelMock.
	self assert: trait class slots size equals: 2
]
