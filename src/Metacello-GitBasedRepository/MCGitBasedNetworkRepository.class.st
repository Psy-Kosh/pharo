Class {
	#name : #MCGitBasedNetworkRepository,
	#superclass : #MCRepository,
	#instVars : [
		'projectPath',
		'projectVersion',
		'repoPath',
		'projectVersionPattern',
		'localRepository'
	],
	#classInstVars : [
		'repoCacheDirectory',
		'repoDownloadCache',
		'siteUsername',
		'sitePassword'
	],
	#category : #'Metacello-GitBasedRepository'
}

{ #category : #accessing }
MCGitBasedNetworkRepository class >> basicDescription [
  ^ self subclassResponsibility
]

{ #category : #private }
MCGitBasedNetworkRepository class >> cacheDirectory [
  self resetCacheDirectoryIfInvalid.
  repoCacheDirectory ifNil: [ repoCacheDirectory := self defaultCacheDirectory ].
  ^ repoCacheDirectory
]

{ #category : #private }
MCGitBasedNetworkRepository class >> cacheDirectory: aDirectory [
  "explicitly set repoCacheDirectory"

  repoCacheDirectory := aDirectory
]

{ #category : #private }
MCGitBasedNetworkRepository class >> cacheDirectoryFor: projectPath [
	| cacheDirectory projectDirectory |
	
	cacheDirectory := self cacheDirectory.
	projectDirectory := MetacelloPlatform current directoryFromPath: projectPath relativeTo: cacheDirectory.
	MetacelloPlatform current ensureDirectoryExists: projectDirectory.
	^ projectDirectory
]

{ #category : #accessing }
MCGitBasedNetworkRepository class >> cacheDirectoryPath [
  ^ MCFileTreeFileUtils current directoryPathString: self cacheDirectory
]

{ #category : #accessing }
MCGitBasedNetworkRepository class >> cacheDirectoryPath: aString [
  self
    cacheDirectory:
      (aString
        ifEmpty: [  ]
        ifNotEmpty: [ MetacelloPlatform current fileHandleOn: aString ])
]

{ #category : #private }
MCGitBasedNetworkRepository class >> defaultCacheDirectory [
  | defaultDirectory cacheDirectory |
  defaultDirectory := MetacelloPlatform current defaultDirectory.
  cacheDirectory := MetacelloPlatform current
    directoryFromPath: self basicDescription , '-cache'
    relativeTo: defaultDirectory.
  MetacelloPlatform current ensureDirectoryExists: cacheDirectory.
  ^ cacheDirectory
]

{ #category : #accessing }
MCGitBasedNetworkRepository class >> description [
  ^ self basicDescription , '://'
]

{ #category : #accessing }
MCGitBasedNetworkRepository class >> downloadCache [
  repoDownloadCache ifNil: [ repoDownloadCache := Dictionary new ].
  ^ repoDownloadCache
]

{ #category : #accessing }
MCGitBasedNetworkRepository class >> downloadCacheKey: projectPath version: versionString [
  ^ projectPath , ':::' , versionString
]

{ #category : #initialization }
MCGitBasedNetworkRepository class >> flushDownloadCache [
  "self flushDownloadCache"

  repoDownloadCache := nil
]

{ #category : #utilities }
MCGitBasedNetworkRepository class >> flushProjectEntry: projectPath version: versionString [
    self downloadCache removeKey: (self downloadCacheKey: projectPath version: versionString) ifAbsent: [  ]
]

{ #category : #initialization }
MCGitBasedNetworkRepository class >> initialize [
  "self initialize"

	(Smalltalk classNamed: #SessionManager)
		ifNotNil: [ :c | c default perform: #registerNetworkClassNamed: with: self name ]
		ifNil:[ Smalltalk addToStartUpList: self ].
  self flushDownloadCache.
  self resetCacheDirectoryIfInvalid
]

{ #category : #accessing }
MCGitBasedNetworkRepository class >> isAbstract [
    "abstract as far as creating new repositories interactively? yes"

    ^ true
]

{ #category : #testing }
MCGitBasedNetworkRepository class >> isEnabled [

	^false
]

{ #category : #'instance creation' }
MCGitBasedNetworkRepository class >> location: locationUrl [
    ^ self location: locationUrl version: nil
]

{ #category : #'instance creation' }
MCGitBasedNetworkRepository class >> location: locationUrl version: versionString [
    ^ self parseLocation: locationUrl version: versionString
]

{ #category : #private }
MCGitBasedNetworkRepository class >> parseLocation: locationUrl version: versionString [
  "self 
	parseLocation: 'github://dalehenrich/MetacelloRepository:master/monticello/repos/itory/path'
	version: nil
     "

  | projectPath projectVersion repoPath headerSize desc projectDelim repoDelim versionDelim |
  headerSize := self description size.
  desc := locationUrl.
  desc := desc copyFrom: headerSize + 1 to: desc size.
  projectVersion := repoPath := nil.
  projectDelim := desc indexOf: $/.
  repoDelim := desc indexOf: $/ startingAt: projectDelim + 1.
  (versionDelim := desc indexOf: $:) == 0
    ifTrue: [ 
      repoDelim == 0
        ifTrue: [ projectPath := desc ]
        ifFalse: [ 
          projectPath := desc copyFrom: 1 to: repoDelim - 1.
          repoPath := desc copyFrom: repoDelim + 1 to: desc size ] ]
    ifFalse: [ 
      projectPath := desc copyFrom: 1 to: versionDelim - 1.
      repoDelim == 0
        ifTrue: [ projectVersion := desc copyFrom: versionDelim + 1 to: desc size ]
        ifFalse: [ 
          projectPath := desc copyFrom: 1 to: versionDelim - 1.
          self
            parseProjectVersionField: [ :pv :rp | 
              projectVersion := pv.
              repoPath := rp ]
            desc: desc
            versionDelim: versionDelim ] ].
  versionString ~~ nil
    ifTrue: [ projectVersion := versionString ].
  ^ self new
    projectPath: projectPath
    projectVersion: projectVersion
    repoPath: repoPath
]

{ #category : #private }
MCGitBasedNetworkRepository class >> parseProjectVersionField: parseBlock desc: desc versionDelim: versionDelim [
  "Issue #234: have to allow for commitish containing slashes"

  | strm done escaped repoDelim |
  strm := WriteStream on: String new.
  repoDelim := versionDelim + 1.
  escaped := done := false.
  [ done ]
    whileFalse: [ 
      | char |
      repoDelim > desc size
        ifTrue: [ done := true ]
        ifFalse: [ 
          char := desc at: repoDelim.
          char == $\
            ifTrue: [ 
              escaped
                ifTrue: [ 
                  "$\ not legal in branch name ... literally ignored"
                  escaped := false ]
                ifFalse: [ escaped := true ] ]
            ifFalse: [ 
              char == $/
                ifTrue: [ 
                  escaped
                    ifFalse: [ done := true ] ].
              done
                ifFalse: [ strm nextPut: char ].
              escaped := false ].
          repoDelim := repoDelim + 1 ] ].
  repoDelim := repoDelim - 1.
  parseBlock
    value: strm contents
    value: (desc copyFrom: repoDelim + 1 to: desc size)
]

{ #category : #utilities }
MCGitBasedNetworkRepository class >> projectDirectoryFrom: projectPath version: versionString [
	| mcPlatform theCacheDirectory projectDirectory downloadCacheKey cachePath pid |
	downloadCacheKey := self
		downloadCacheKey: projectPath
		version: versionString.
	mcPlatform := MetacelloPlatform current.
	theCacheDirectory := mcPlatform
		directoryFromPath: versionString
		relativeTo: (self cacheDirectoryFor: projectPath).
	cachePath := self downloadCache at: downloadCacheKey ifAbsent: [  ].
	(cachePath isNil
		or: [ (projectDirectory := mcPlatform
				directoryFromPath: cachePath
				relativeTo: theCacheDirectory) exists not ])
		ifTrue: [ | url archive directory zipFileName |
			MetacelloScriptGitBasedDownloadNotification new
				projectPath: projectPath;
				versionString: versionString;
				signal.	"for testing purposes"
			mcPlatform ensureDirectoryExists: theCacheDirectory.
			url := self
				projectZipUrlFor: projectPath
				versionString: versionString.
			pid := mcPlatform processPID.
			zipFileName := mcPlatform
				tempFileFor:
					self basicDescription , '-' , pid , '-'
						, (downloadCacheKey select: [ :c | c isAlphaNumeric ])
				suffix: '.zip'.
			archive := mcPlatform
				downloadZipArchive: url
				to: zipFileName.
			directory := mcPlatform
				directoryFromPath: (cachePath := archive members first fileName)
				relativeTo: theCacheDirectory.
			mcPlatform closeZipArchive: archive.
			directory exists
				ifTrue: [ mcPlatform deleteFileNamed: zipFileName ]
				ifFalse: [ mcPlatform
						extractRepositoryFrom: zipFileName
						to: theCacheDirectory fullName ].
			self downloadCache at: downloadCacheKey put: cachePath.
			projectDirectory := mcPlatform
				directoryFromPath: cachePath
				relativeTo: theCacheDirectory ].
	^ projectDirectory
]

{ #category : #'version patterns' }
MCGitBasedNetworkRepository class >> projectVersionFromString: aString [
  "strip leading $v if present and return an instance of MetacelloVersionNumber"

  | versionString |
  versionString := aString.
  (versionString beginsWith: 'v')
    ifTrue: [ versionString := versionString copyFrom: 2 to: versionString size ].
  ^ MetacelloVersionNumber fromString: versionString
]

{ #category : #private }
MCGitBasedNetworkRepository class >> projectZipUrlFor: projectPath versionString: versionString [
  self subclassResponsibility
]

{ #category : #private }
MCGitBasedNetworkRepository class >> resetCacheDirectoryIfInvalid [
  "Reset if invalid"

  repoCacheDirectory notNil
    and: [ 
      (MCFileTreeFileUtils current directoryExists: repoCacheDirectory)
        ifFalse: [ repoCacheDirectory := nil ] ]
]

{ #category : #'site credentials' }
MCGitBasedNetworkRepository class >> sitePassword [
  ^ sitePassword
]

{ #category : #'site credentials' }
MCGitBasedNetworkRepository class >> sitePassword: aString [
  sitePassword := aString
]

{ #category : #'site credentials' }
MCGitBasedNetworkRepository class >> siteUsername [
  ^ siteUsername
]

{ #category : #'site credentials' }
MCGitBasedNetworkRepository class >> siteUsername: aString [
  siteUsername := aString
]

{ #category : #'site credentials' }
MCGitBasedNetworkRepository class >> siteUsername: username sitePassword: pass [
  "MCBitbucketRepository siteUsername: '' sitePassword: ''"

  "MCGitHubRepository siteUsername: '' sitePassword: ''"

  self
    siteUsername: username;
    sitePassword: pass
]

{ #category : #'system startup' }
MCGitBasedNetworkRepository class >> startUp: resuming [
    "Flush the GitHub download cache"

    resuming
        ifTrue: [ self flushDownloadCache ]
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> allFileNames [
	self flag: #review. "This will fail in non filtree(cypress) formats, but I need to 
	 implement it to make the tests pass. A better approach maybe to look at those tests 
	 and try to implement them better."
	^ self localRepository allFileNames
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> asRepositorySpecFor: aMetacelloMCProject [
  ^ aMetacelloMCProject repositorySpec
    description: self description;
    type: self class basicDescription;
    yourself
]

{ #category : #private }
MCGitBasedNetworkRepository >> calculateRepositoryDirectory [
	 | directory |
	
	directory := self class
		projectDirectoryFrom: self projectPath
		version: self projectVersion.
	self repoPath isEmpty ifFalse: [
		directory := MetacelloPlatform current
			directoryFromPath: self repoPath
 			relativeTo: directory ].
		
	^ directory
]

{ #category : #initialization }
MCGitBasedNetworkRepository >> canUpgradeTo: anMCGitBasedRepository [
  (anMCGitBasedRepository isKindOf: self class)
    ifFalse: [ ^ false ].
  ^ self projectPath = anMCGitBasedRepository projectPath
    and: [ self repoPath = anMCGitBasedRepository repoPath ]
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> closestAncestorVersionFor: anAncestry ifNone: errorBlock [
	^ self localRepository 
		closestAncestorVersionFor: anAncestry 
		ifNone: errorBlock
]

{ #category : #descriptions }
MCGitBasedNetworkRepository >> description [
  | desc |
  desc := self class description , self projectPath , ':'
    , self projectVersionEscaped.
  self repoPath isEmpty
    ifTrue: [ ^ desc ].
  ^ desc , '/' , self repoPath
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> directory [
  ^ self localRepository directory
]

{ #category : #private }
MCGitBasedNetworkRepository >> downloadJSONTags [
  | tagsUrl jsonObject |
  tagsUrl := self projectTagsUrlFor: self projectPath.
  jsonObject := MetacelloPlatform current
    downloadJSON: tagsUrl
    username: self class siteUsername
    pass: self class sitePassword.
  ^ self normalizeTagsData: jsonObject
]

{ #category : #private }
MCGitBasedNetworkRepository >> ensureLocalRepository [
	localRepository ifNotNil: [ ^ self ].
	self resolveLocalRespository
]

{ #category : #initialization }
MCGitBasedNetworkRepository >> flushCache [
  "the directory acts like a cache since we download the directory from a git-based repository (github, bitbucket, etc.)"
	| directory |

	[ localRepository flushCache ]
	on: Error
	do: [ :ex | 
		SystemNotification signal: 'Error for: ' , self description printString , ' during flushCache: ', ex description printString ].
	self class flushDownloadCache.
	
	directory := self calculateRepositoryDirectory.
	directory exists 
		ifTrue: [ localRepository directory: directory ]
		ifFalse: [ localRepository resetDirectory ]
]

{ #category : #initialization }
MCGitBasedNetworkRepository >> flushForScriptGet [

	self class 
		flushProjectEntry: self projectPath 
		version: self projectVersion.
    self localRepository flushForScriptGet
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> goferReferences [
	"delegate collection to local repository, but change them to be from *this* repository."

	^ self localRepository goferReferences 
		collect: [ :each | 
			GoferResolvedReference 
				name: each name 
				repository: self ]
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> goferVersionFrom: aVersionReference [
	self flag: #review. "This will fail in non filtree(cypress) formats, but I need to 
	 implement it to make the tests pass. A better approach maybe to look at those tests 
	 and try to implement them better."
	^ self localRepository goferVersionFrom: aVersionReference
]

{ #category : #'initialize-release' }
MCGitBasedNetworkRepository >> hasNoLoadConflicts: anMCGitBasedRepository [
  (anMCGitBasedRepository isKindOf: self class)
    ifFalse: [ ^ false ].
  ^ self projectPath = anMCGitBasedRepository projectPath
    and: [ 
      self repoPath = anMCGitBasedRepository repoPath
        and: [ self projectVersion = anMCGitBasedRepository projectVersion ] ]
]

{ #category : #comparing }
MCGitBasedNetworkRepository >> hash [
    ^ self description hash
]

{ #category : #testing }
MCGitBasedNetworkRepository >> includesVersionNamed: aString [
	^ self localRepository includesVersionNamed: aString
]

{ #category : #testing }
MCGitBasedNetworkRepository >> isValid [
    ^ true
]

{ #category : #private }
MCGitBasedNetworkRepository >> localRepository [
	self ensureLocalRepository.
	self validateLocalRepository.
	^ localRepository
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> metacelloProjectClassFor: aScriptEngine [
    ^ MetacelloMCBaselineProject
]

{ #category : #private }
MCGitBasedNetworkRepository >> normalizeTagsData: jsonObject [
  ^ self subclassResponsibility
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> possiblyNewerVersionsOfAnyOf: someVersions [
	^ self localRepository possiblyNewerVersionsOfAnyOf: someVersions
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectPath [
    ^ projectPath
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectPath: anObject [
    projectPath := anObject
]

{ #category : #initialization }
MCGitBasedNetworkRepository >> projectPath: aProjectPath projectVersion: aProjectVersion repoPath: aRepoPath [
  self projectPath: aProjectPath.
  self projectVersion: aProjectVersion.	"Important that projectVersion be set AFTER projectPath"
  self repoPath: aRepoPath
]

{ #category : #private }
MCGitBasedNetworkRepository >> projectTagsUrlFor: aProjectPath [
	self subclassResponsibility
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectVersion [
    (projectVersion == nil or: [ projectVersion isEmpty ])
        ifTrue: [ projectVersion := 'master' ].
    ^ projectVersion
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectVersion: aString [
  "Important that projectVersion be set AFTER projectPath, as projectPath needed for resolving projectVersionPattern"

  | x |
  aString
    ifNil: [ 
      projectVersion := aString.
      ^ self ].
  (x := aString
    findDelimiters:
      {$#.
      $*.
      $?}
    startingAt: 1) <= aString size
    ifTrue: [ self resolveProjectVersionPattern: aString ]
    ifFalse: [ projectVersion := aString ]
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectVersionEscaped [
  | pv |
  pv := self projectVersion.
  (projectVersion includes: $/)
    ifTrue: [ ^ pv copyReplaceAll: '/' with: '\/' ].
  ^ pv
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectVersionPattern [
  "do not set projectVersionPattern unless it _is_ a pattern: includes $#, %*, or $?"

  projectVersionPattern ifNil: [ ^ self projectVersion ].
  ^ projectVersionPattern
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> projectVersionPattern: aString [
  "do not set projectVersionPattern unless it _is_ a pattern: includes $#, %*, or $?"

  projectVersionPattern := aString
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> repoPath [
  repoPath ifNil: [ repoPath := '' ].
  ^ repoPath
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> repoPath: anObject [
    repoPath := anObject
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> repositoryBranchName [
  "for git-based network repos, answer the value of the projectVersion field"

  ^ self projectVersion
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> repositoryVersionString [
  "for git-based network repos, answer the SHA associated with the download: a commit SHA or tag SHA"

  | versionComponents versionElement pathElements gitBasedPath repositoryDirPath projectDirPath projectDir projectVersionDir |
  repositoryDirPath := self directory fullName.
  projectDir := self class cacheDirectoryFor: self projectPath.
  projectVersionDir := MCFileTreeFileUtils current
    directoryFromPath: self projectVersion
    relativeTo: projectDir.
  projectDirPath := projectVersionDir fullName.
  (repositoryDirPath beginsWith: projectDirPath)
    ifFalse: [ ^ self projectVersion ].
  gitBasedPath := repositoryDirPath
    copyFrom: projectDirPath size + 2
    to: repositoryDirPath size.
  pathElements := gitBasedPath findTokens: '/'.
  versionElement := pathElements at: 1.
  versionComponents := versionElement findTokens: '-'.
  ^ versionComponents last
]

{ #category : #private }
MCGitBasedNetworkRepository >> resolveLocalRespository [
	| directory directoryPath |
  
	directory := self calculateRepositoryDirectory.
	directoryPath := MCFileTreeFileUtils current directoryPathString: directory.
	directory ifAbsent: [ self error: 'Local directory ', directoryPath, ' does not exist.' ].
	localRepository := MetacelloPlatform current createRepository: (MetacelloRepositorySpec new 
		description: 'filetree://', directoryPath;
		yourself)
]

{ #category : #private }
MCGitBasedNetworkRepository >> resolveProjectVersionPattern: aString [
  "aString must conform to the syntax for MetacelloVersionNumber with the exception that aString may have a leading $v which is stripped before conversion to a MetacelloVersionNumber patterm"

  | patternString tagDictionary matchingTags tagAssocs sortedMatchingTags theTag |
  self projectPath
    ifNil: [ self error: 'projectPath must be set to resolve project version pattern.' ].
  patternString := (self class projectVersionFromString: aString) asString.
  tagDictionary := self downloadJSONTags.
  tagAssocs := tagDictionary keys
    collect: [ :tagName | 
      | tagVersion |
      tagVersion := self class projectVersionFromString: tagName.
      tagVersion -> tagName ].
  matchingTags := tagAssocs select: [ :assoc | assoc key match: patternString ].
  matchingTags isEmpty
    ifTrue: [ 
      projectVersion := aString.
      ^ self
        error:
          'No tags matching the pattern ' , aString printString
            , ' found for repository description '
            , self description printString ].
  sortedMatchingTags := matchingTags asArray sort: [ :a :b | a key <= b key ].
  theTag := sortedMatchingTags last.
  projectVersionPattern := aString.
  projectVersion := theTag value
]

{ #category : #storing }
MCGitBasedNetworkRepository >> storeVersion: aVersion [
	^ self localRepository storeVersion: aVersion
]

{ #category : #private }
MCGitBasedNetworkRepository >> validateLocalRepository [
	| dir |

	dir := self calculateRepositoryDirectory.
	(dir = localRepository directory 
		and: [ MCFileTreeFileUtils current directoryExists: dir ]) 
		ifTrue: [ ^ self ].
	self flushCache.
 	self resolveLocalRespository.
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> versionFrom: aVersionReferenceString [
	^ self localRepository versionFrom: aVersionReferenceString
]

{ #category : #accessing }
MCGitBasedNetworkRepository >> versionWithInfo: aVersionInfo ifAbsent: errorBlock [
	^ self localRepository 
		versionWithInfo: aVersionInfo 
		ifAbsent: errorBlock
]
