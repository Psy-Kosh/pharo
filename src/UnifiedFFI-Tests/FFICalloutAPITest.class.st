"
Tests for FFICalloutAPI
"
Class {
	#name : #FFICalloutAPITest,
	#superclass : #TestCase,
	#instVars : [
		'senderCtx',
		'uffiCtx',
		'lastUffiCtx'
	],
	#category : #'UnifiedFFI-Tests-Tests'
}

{ #category : #running }
FFICalloutAPITest >> ffiCalloutClass [
	^ FFICalloutAPI
]

{ #category : #'primitives atomic' }
FFICalloutAPITest >> ffiCopyString: aString to: dest [
	^ self ffiCall: #( String strcpy ( void* dest, String aString ) )
]

{ #category : #'primitives atomic' }
FFICalloutAPITest >> ffiDoubleAbs: number [ 
	^ self ffiCall: #( double DoubleAbsolute (double number) ) options: #(+optCallbackCall)
]

{ #category : #'primitives atomic' }
FFICalloutAPITest >> ffiFloatAbs: number [ 
	^ self ffiCall: #( float FloatAbsolute (float number) ) options: #(+optCallbackCall)
]

{ #category : #'primitives atomic' }
FFICalloutAPITest >> ffiIntAbs: number [
	^ self ffiCall: #( int abs ( int number ) )
]

{ #category : #accessing }
FFICalloutAPITest >> ffiLibraryName [
	^ LibC
]

{ #category : #'primitives atomic' }
FFICalloutAPITest >> ffiLongLongAbs: number [
	^ self ffiCall: #( longlong llabs (longlong number) )
]

{ #category : #'primitives constant' }
FFICalloutAPITest >> ffiTestConstantFormat: format to: buffer [
	^ self ffiCall: #( int sprintf ( ByteArray buffer, String format, 65, 65, 1 ) ) fixedArgumentCount: 2
]

{ #category : #'primitives constant' }
FFICalloutAPITest >> ffiTestContantFormat: format value: aNumber to: buffer [
	^ self ffiCall: #( int sprintf ( ByteArray buffer, String format, 65, 65, long aNumber ) ) fixedArgumentCount: 2
]

{ #category : #'primitives atomic' }
FFICalloutAPITest >> ffiToLower: c [
	^ self ffiCall: #( char tolower (char c) )
]

{ #category : #accessing }
FFICalloutAPITest >> method1 [ 
	| object index |
	object := FFICalloutObjectForTest new.
	index := FFICalloutObjectForTest class instVarIndexFor: #handle ifAbsent: [ nil ].
	^ object instVarAt: index.
]

{ #category : #'primitives pointer' }
FFICalloutAPITest >> primFromByteArray: src toExternalAddress: dest size: n [
	^ self 
		ffiCall: #( void *memcpy(void* dest, ByteArray src, size_t n) )
		module: LibC
]

{ #category : #'primitives pointer' }
FFICalloutAPITest >> primMemMoveFrom: src to: dest size: n [
	^ self 
		ffiCall: #( void *memcpy(void *dest, const void *src, size_t n) )
		module: LibC
]

{ #category : #'primitives pointer' }
FFICalloutAPITest >> primStr: aString cat: otherString [  
	^ self 
		ffiCall: #( char *strcat ( void *aString, void *otherString ) )
		module: LibC

]

{ #category : #running }
FFICalloutAPITest >> resetFFIMethods [
	| ffiMethods |
	ffiMethods := FFICalloutAPITest methodDict select: [ :method | (method selector beginsWith: 'ffi') or: [method selector beginsWith: 'prim'] ].
	ffiMethods do: #recompile
]

{ #category : #running }
FFICalloutAPITest >> setUp [

	super setUp.
	self resetFFIMethods.
	senderCtx := Context
		sender: nil
		receiver: nil
		method: Object>>#yourself
		arguments: #().
	
	uffiCtx := Context
		sender: senderCtx
		receiver: nil
		method: Object>>#ffiCall:
		arguments: #(1).
		
	lastUffiCtx := Context
		sender: uffiCtx
		receiver: nil
		method: Object>>#ffiCall:options:
		arguments: #(1 2).
]

{ #category : #running }
FFICalloutAPITest >> tearDown [
	FFICallbackFunctionResolution reset.
	super tearDown.
]

{ #category : #'tests pointer' }
FFICalloutAPITest >> testByteArrayToExternalAddress [
	| result dest |
	

	result := self 
		primFromByteArray: ('Hello, World' asByteArray pinInMemory; yourself) 
		toExternalAddress: (dest := ExternalAddress allocate: 12) autoRelease 
		size: 12.
		
	self assert: (dest copyFrom: 1 to: 12) asString equals: 'Hello, World'.
	
]

{ #category : #'tests constant' }
FFICalloutAPITest >> testCallWithAllConstParameter [
	"Tests a function in the form: 
	
	self nbCall: #( long ffiTestInts ( 65, 65, 65, long aNumber ) )
	
	(passing constants as parameters)
	"
	| result buffer |

	self skipOnAppleARM.

	buffer := (ByteArray new: 100)
		pinInMemory;
		yourself. 
	result := self ffiTestConstantFormat: '%d, %d and %d' to: buffer.
	self assert: result equals: 12.
	self assert: (buffer first: result) asString equals: '65, 65 and 1'
]

{ #category : #'tests constant' }
FFICalloutAPITest >> testCallWithConstParameter [
	"Tests a function in the form: 
	
	self nbCall: #( long ffiTestInts ( 65, 65, 65, long aNumber ) )
	
	(passing constants as parameters)
	"
	| result buffer |

	self skipOnAppleARM.

	buffer := (ByteArray new: 100)
		pinInMemory; yourself.
	
	result := self ffiTestContantFormat: '%d, %d and %d' value: true to: buffer.
	self assert: result equals: 12.
	self assert: (buffer first: result) asString equals: '65, 65 and 1'
]

{ #category : #'tests object' }
FFICalloutAPITest >> testCallWithObjectCreation [
	"Test a call of the form: 
	
		self nbCall: #( NBFFICalloutVMObjectForTest malloc ( size_t size ) )
		
		(obtaining an object as result)
	"
	| object |
	
	[
		self shouldnt: [ object := FFICalloutObjectForTest primCreate: 1 ] raise: Error.
		self assert: object notNil.
		self assert: object class equals: FFICalloutObjectForTest.
		self assert: object handle notNil.
		self deny: object handle isNull ]
	ensure: [ 
		object ifNotNil: [ object free ] ]
]

{ #category : #'tests object' }
FFICalloutAPITest >> testCallWithObjectParameter [
	"Test a call of the form: 
	
		self nbCall: #( void function ( self ) )
		
		(passing self as parameter)
	"
	| object text |
	
	text := 'Hello, World'.
	object := FFICalloutObjectForTest new
		handle: (ByteArray new: text size + 1);
		yourself. 
	
	self 
		shouldnt: [ FFICalloutObjectForTest primObject: object strcpy: text ] 
		raise: Error.
	self assert: object handle asString equals: (text copyWith: (Character value: 0))
]

{ #category : #'tests object' }
FFICalloutAPITest >> testCallWithSelfParameter [
	"Test a call of the form: 
	
		self nbCall: #( void function ( self ) )
		
		(passing self as parameter)
	"
	| object |
	
	object := FFICalloutObjectForTest new. 
	self 
		shouldnt: [ object strcpy: 'Hello, World' ] 
		raise: Error.
	"Since is a strcpy it will answer a byte array terminated in zero"
	self assert: object handle asString equals: ('Hello, World' copyWith: (Character value: 0))
]

{ #category : #'tests atomic' }
FFICalloutAPITest >> testCharCall [
	"Test using generic FFI spec"
	| result  |
	
	result := self ffiToLower: $A.
	self assert: result equals: $a.
	 
	result := self ffiToLower: 65.
	self assert: result equals: $a.
	
	result := self ffiToLower: 65.0.
	self assert: result equals: $a.

	result := self ffiToLower: true.
	self assert: result equals: (Character value: 1)

]

{ #category : #'tests pointer' }
FFICalloutAPITest >> testCharPointer [
	| result buffer |
	
	buffer := ByteArray new: 512.
	buffer writeString: 'Hello, '.
		
	result := self 
		primStr:  buffer
		cat: 'World'.
				
	self assert: result equals: 'Hello, World'.
]

{ #category : #'tests pointer' }
FFICalloutAPITest >> testForwardedObjects [
	| result dest |
	dest := ByteArray new: 12.
	"Pinning an object replaces it with a forwarded."
	"We want to force the object to be forwarded by the ffi call primitive"
	dest pinInMemory.
		
	result := self 
		primMemMoveFrom: 'Hello, World' asByteArray 
		to: dest 
		size: 12.
		
	self deny: result isNull.	
	self assert: dest asString equals: 'Hello, World'
]

{ #category : #'tests atomic' }
FFICalloutAPITest >> testIntCall [
	"Test using generic FFI spec"
	| result |
	
	result := self ffiIntAbs: 65.
	self assert: result equals: 65.
	
	result := self ffiIntAbs: 65.0.
	self assert: result equals: 65.

	result := self ffiIntAbs: $A.
	self assert: result equals: 65.

	result := self ffiIntAbs: true.
	self assert: result equals: 1.

]

{ #category : #'tests atomic' }
FFICalloutAPITest >> testLongLongs [
	"Test passing and returning longlongs"
	| long1 long2 result  |
	
	"This test fails in windows, but it is expected (is because the funtion used is in 
	 another library)"
	Smalltalk os isWindows ifTrue: [ ^ self skip ].		
	
	long1 := 16r123456789012.
	long2 := (-1 << 31).
		
	result := self ffiLongLongAbs: long1.
	self assert: result equals: long1.
	
	result := self ffiLongLongAbs: long2.
	self assert: result equals: long2 abs
]

{ #category : #'tests atomic' }
FFICalloutAPITest >> testPrintString [
	"Test using generic FFI spec"
	| result buffer |
	
	buffer := (ByteArray new: 12)
			pinInMemory;
			yourself.
	result := self ffiCopyString: 'Hello World!' to: buffer.
	self assert: result equals: 'Hello World!'.
	self assert: buffer asString equals: 'Hello World!'
]

{ #category : #'tests context' }
FFICalloutAPITest >> testSenderLookupsMethodInSenderChain [
	| api |
	
	api := FFICalloutAPI inUFFIContext: uffiCtx.
	self assert: api senderContext equals: senderCtx
]

{ #category : #'tests context' }
FFICalloutAPITest >> testSenderLookupsMethodInSenderChainWithManyUFFIMethods [
	| api |
	
	api := FFICalloutAPI inUFFIContext: lastUffiCtx.

	self assert: api senderContext equals: senderCtx
]

{ #category : #'tests pointer' }
FFICalloutAPITest >> testVoidPointer [
	| result dest |
	
	result := self 
		primMemMoveFrom: 'Hello, World' asByteArray 
		to: (dest := ByteArray new: 12) 
		size: 12.
		
	self deny: result isNull.	
	self assert: dest asString equals: 'Hello, World'
]

{ #category : #'tests context' }
FFICalloutAPITest >> testuFFIMethodSelectorInNonMarkedContextDoesNotFindAMethodEnterSelector [
	| api selector |
	
	api := FFICalloutAPI inUFFIContext: senderCtx.
	selector := api uFFIEnterMethodSelector.

	self assert: selector equals: nil
]

{ #category : #'tests context' }
FFICalloutAPITest >> testuFFIMethodSelectorLookupsFirstMethodInSenderChain [
	| api selector |
	
	api := FFICalloutAPI inUFFIContext: lastUffiCtx.
	selector := api uFFIEnterMethodSelector.

	self assert: selector equals: uffiCtx method selector
]

{ #category : #'tests context' }
FFICalloutAPITest >> testuFFIMethodSelectorLookupsMethodInSenderChain [
	| api selector |
	
	api := FFICalloutAPI inUFFIContext: uffiCtx.
	selector := api uFFIEnterMethodSelector.

	self assert: selector equals: uffiCtx method selector
]
