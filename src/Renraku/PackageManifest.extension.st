Extension { #name : #PackageManifest }

{ #category : #'*Renraku' }
PackageManifest class >> forcedRules [

	"override this method and return all the rule names that have to be applied to your package despite global bans"

	^ #()
]
