"
I decorate table with bold font for method groups and methods when full browser shows the class side
"
Class {
	#name : #ClyClassSideBoldTableDecorator,
	#superclass : #ClyTableDecorator,
	#category : #'Calypso-SystemTools-FullBrowser-UI'
}

{ #category : #decoration }
ClyClassSideBoldTableDecorator class >> decorateTableCell: anItemCellMorph of: aDataSourceItem [

	anItemCellMorph label clyAddEmphasis: TextEmphasis bold
]

{ #category : #decoration }
ClyClassSideBoldTableDecorator class >> methodDecorationStrategy [
	<classAnnotation>
	
	^ClyTableDecorationStrategyAnnotation for: ClyFullBrowserMethodContext
]

{ #category : #decoration }
ClyClassSideBoldTableDecorator class >> methodGroupDecorationStrategy [
	<classAnnotation>
	
	^ClyTableDecorationStrategyAnnotation for: ClyFullBrowserMethodGroupContext
]

{ #category : #decoration }
ClyClassSideBoldTableDecorator class >> variableDecorationStrategy [
	<classAnnotation>
	
	^ClyTableDecorationStrategyAnnotation for: ClyFullBrowserVariableContext
]

{ #category : #testing }
ClyClassSideBoldTableDecorator class >> wantsDecorateTableCellOf: aDataSourceItem [

	^aDataSourceItem browser metaLevelScope = ClyClassSideScope
]
