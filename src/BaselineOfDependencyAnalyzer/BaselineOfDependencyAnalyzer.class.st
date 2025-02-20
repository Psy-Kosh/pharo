Class {
	#name : #BaselineOfDependencyAnalyzer,
	#superclass : #BaselineOf,
	#category : #BaselineOfDependencyAnalyzer
}

{ #category : #baselines }
BaselineOfDependencyAnalyzer >> baseline: spec [
	<baseline>
	
	spec for: #'common' do: [
			
		self graphAlgorithms: spec.
		
		spec 
			package: 'Tool-DependencyAnalyser'
				 with: [ spec requires: #('AIGraphAlgorithms') ];
			package: 'Tool-DependencyAnalyser-UI';
			package: 'Tool-DependencyAnalyser-Tests';
			package: 'Tool-DependencyAnalyser-Tests-Data'.
			
		spec 
			group: 'Core' with: #('Tool-DependencyAnalyser' 'Tool-DependencyAnalyser-UI');
			group: 'Tests' with: #('Tool-DependencyAnalyser-Tests' 'Tool-DependencyAnalyser-Tests-Data');
			group: 'default' with: #('Core' 'Tests') ]
]

{ #category : #baselines }
BaselineOfDependencyAnalyzer >> graphAlgorithms: spec [ 

	spec baseline: 'AIGraphAlgorithms' with: [
		spec repository: 'github://pharo-ai/graph-algorithms:v1.0.0/src' ].
]
