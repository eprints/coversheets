package EPrints::Plugin::Screen::EPrint::Staff::Coversheet;

@ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
    my( $class, %params ) = @_;

    my $self = $class->SUPER::new(%params);

    # $self->{priv} = # no specific priv - one per action

    $self->{actions} = [qw/ update /];

    $self->{appears} = [ {
        place => "eprint_editor_actions",
	action => "update",
        position => 1982,
    }, ];

    return $self;
}

sub obtain_lock
{
        my( $self ) = @_;

        return $self->could_obtain_eprint_lock;
}

sub about_to_render 
{
        my( $self ) = @_;

        $self->EPrints::Plugin::Screen::EPrint::View::about_to_render;
}

sub can_be_viewed
{
    my( $self ) = @_;

    return 0 unless $self->could_obtain_eprint_lock;

    my $repo = $self->repository;
    my $eprint = $self->{processor}->{eprint};

    my $documents = $eprint->get_all_documents;
    my $has_pdf_doc = 0;
    foreach my $doc ( $eprint->get_all_documents )
    {
        if ( $doc->get_value( 'mime_type' ) eq 'application/pdf' )
	{
	    $has_pdf_doc = 1;
            last;
        }
    }

    return 0 unless $has_pdf_doc;

    return 1;
}


sub allow_update
{
        my( $self ) = @_;

        return 0 unless $self->could_obtain_eprint_lock;
        return $self->allow( "eprint/edit:editor" );
}

sub action_update
{
        my( $self ) = @_;

        my $session = $self->{session};
        my $eprint = $self->{processor}->{eprint};

        foreach my $doc ( $eprint->get_all_documents() )
        {
		if ( $doc->get_value( 'coversheet_error' ) eq "1" )
		{
	                $doc->set_value( 'coversheet_error', undef );
			$doc->commit;
		}
        }

	if ( $eprint->get_value( 'coversheets_dirty' ) ne 'TRUE' ) 
	{
		$eprint->set_value( 'coversheets_dirty', 'TRUE' );
		$eprint->commit;
	}
        $self->add_result_message( 1 );
}

sub add_result_message
{
        my( $self, $ok ) = @_;

        if( $ok )
        {
                $self->{processor}->add_message( "message",
                        $self->html_phrase( "updating_coversheet" ) );
        }
        else
        {
                $self->{processor}->add_message( "coversheet_not_updated" );
        }

        $self->{processor}->{screenid} = "EPrint::View";
}


1;

