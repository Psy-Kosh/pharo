Class {
	#name : #BaselineOfGeneralTests,
	#superclass : #BaselineOf,
	#category : #BaselineOfGeneralTests
}

{ #category : #baselines }
BaselineOfGeneralTests >> baseline: spec [
	<baseline>
	"Needs to be re-sorted"
	
	spec for: #'common' do: [
		spec 
			package: 'Debugging-Utils-Tests';
			package: 'Tests';
			package: 'NumberParser-Tests';
			package: 'AST-Core-Tests';			
			package: 'RPackage-Tests';
			package: 'Monticello-Tests';	"required by MonticelloMocks"
			package: 'System-Installers-Tests' ;
			package: 'MonticelloMocks';
			package: 'Fuel-Tests-Core';
			package: 'FormCanvas-Tests';
			package: 'Collections-DoubleLinkedList-Tests';
			package: 'Collections-Arithmetic-Tests';
			package: 'ConfigurationCommandLineHandler-Tests';
			package: 'MetacelloCommandLineHandler-Tests';
			package: 'Debugger-Model-Tests';
			package: 'Debugger-Oups-Tests';		
			package: 'EmbeddedFreeType-Tests';
			
			package: 'Ombu-Tests';
			package: 'Epicea-Tests';
			package: 'Hiedra-Tests';
			package: 'EpiceaBrowsers-Tests';
			
			package: 'FileSystem-Tests-Memory';
			package: 'Fonts-Infrastructure-Tests';
			
			package: 'Graphics-Tests';
			package: 'HelpSystem-Tests';

			package: 'Morphic-Tests';
			
			package: 'Morphic-Widgets-FastTable-Tests';
			package: 'NECompletion-Tests';
			package: 'ProfStef-Tests';
			package: 'Regex-Core-Tests';
			package: 'Ring-Definitions-Tests-Monticello';
			package: 'Rubric-Tests';
			package: 'ScriptingExtensions-Tests';
			package: 'STON-Tests';
			package: 'System-Caching-Tests';
			package: 'System-Hashing-Tests';
			package: 'System-History-Tests';
			package: 'System-Localization-Tests';
			package: 'System-SessionManager-Tests';
			package: 'System-Settings-Tests';
			package: 'System-Support-Tests';
			package: 'Text-Diff-Tests';
			package: 'Text-Edition-Tests';
			package: 'Tool-ExternalBrowser-Tests';			
			package: 'Tool-FileList-Tests';
			package: 'Tool-Finder-Tests';
			package: 'Tool-Profilers-Tests';
			package: 'Tool-Workspace-Tests';
			package: 'Tools-CodeNavigation-Tests';
			package: 'Tools-Tests';
			package: 'Zinc-Resource-Meta-Tests';
			package: 'Zinc-HTTP-Examples';
			package: 'Zinc-Tests';	"requires Zinc-Resource-Meta-Tests"
			package: 'System-Identification-Tests'	;	
			package: 'System-DependenciesTests';
			package: 'System-BasicCommandLineHandler-Tests';
			package: 'Transcript-NonInteractive-Tests';
			package: 'PharoDocComment-Tests'	"standalone" ]
]
