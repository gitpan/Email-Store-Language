use ExtUtils::MakeMaker;
WriteMakefile(
	NAME         => 'Email::Store::Language',
	VERSION_FROM => 'lib/Email/Store/Language.pm',
	PREREQ_PM    => {
		'Test::More'       => 0,
		'Email::Store'     => 0,
		'Lingua::Identify' => 0
	},
);
