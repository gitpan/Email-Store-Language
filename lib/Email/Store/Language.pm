package Email::Store::Mail::Language;

use base qw( Email::Store::DBI );

use strict; 
use warnings;

use Email::Store::Mail;
use Lingua::Identify qw( langof );

__PACKAGE__->table( 'mail_language' );
__PACKAGE__->columns( All => qw( mail language ) );
__PACKAGE__->columns( Primary => qw( mail ) );
__PACKAGE__->has_a( mail => 'Email::Store::Mail' );

Email::Store::Mail->might_have( mail_language => 'Email::Store::Mail::Language' => qw( language ) );

sub on_store_order { 81 }

sub on_store {
	my( $self, $mail ) = @_;

	my $language = langof( $mail->simple->body );

	if( $language ) {
		Email::Store::Mail::Language->create( {
			mail     => $mail->id, 
			language => $language
		} );
	}

	for my $list ( $mail->lists ) {
		my $probability = 1 / scalar( $list->posts );
		$list->calculate_language if rand( 1 ) <= $probability;
	}
}

package Email::Store::List;

sub calculate_language {
	my $self = shift;

	my %languages;

	for my $post ( $self->posts ) {
		next unless $post->language;
		$languages{ $post->language }++;
	}

	my( $language ) = sort { $languages{ $b } <=> $languages{ $a } } keys %languages;

	$self->language( $language );
	$self->update;
}

package Email::Store::List::Language;

use base 'Email::Store::DBI';

use Email::Store::List;

__PACKAGE__->table( 'list_language' );
__PACKAGE__->columns( All => qw( list language ) );
__PACKAGE__->columns( Primary => qw( list ) );
__PACKAGE__->has_a( list => 'Email::Store::List' );

Email::Store::List->might_have( list_language => 'Email::Store::List::Language' => qw( language ) );

package Email::Store::Language;

our $VERSION = '0.01';

use base qw( Email::Store::DBI );

=head1 NAME

Email::Store::Language - Add language identification to emails and lists

=head1 SYNOPSIS

Remember to create the database table:

    % make install
    % perl -MEmail::Store="..." -e 'Email::Store->setup'

And now:

    print $mail->language, "\n";

or

    print $list->language, "\n";

=head1 SEE ALSO

=over 4 

=item * Email::Store

=item * Lingua::Identify

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
__DATA__
CREATE TABLE IF NOT EXISTS mail_language (
    mail varchar(255) NOT NULL PRIMARY KEY,                                                 
    language varchar(10)
);
CREATE TABLE IF NOT EXISTS list_language (
    list     varchar(255) NOT NULL PRIMARY KEY,                                                 
    language varchar(10)
);
