
$c->add_trigger( EP_TRIGGER_DOC_URL_REWRITE, sub
{
	my( %args ) = @_;

	my( $request, $doc, $relations, $filename ) = @args{qw( request document relations filename )};
	return EP_TRIGGER_OK unless defined $doc && ref $doc eq "EPrints::DataObj::Document"; # To avoid missing field error with dark documents that do not get coversheeted.

	# check document is a pdf
	my $format = $doc->value( "format" ); # back compatibility
	my $mime_type = defined $doc->value( "mime_type" ) ? $doc->value( "mime_type" ) : "";
	return EP_TRIGGER_OK unless( $format eq "application/pdf" || $mime_type eq "application/pdf" || $filename =~ /\.pdf$/i );

	# ignore thumbnails e.g. http://.../8381/1.haspreviewThumbnailVersion/jacqueline-lane.pdf
	foreach my $rel ( @{$relations || []} )
	{
		return EP_TRIGGER_OK if( $rel =~ /^is\w+ThumbnailVersionOf$/ );
	}

	# ignore volatile documents
	return EP_TRIGGER_OK if $doc->has_relation( undef, "isVolatileVersionOf" );

	my $session = $doc->get_session;
	my $eprint = $doc->get_eprint;

	# search for a coversheet that can be applied to this document
	my $coversheet = EPrints::DataObj::Coversheet->search_by_eprint( $session, $eprint );
	return EP_TRIGGER_OK unless( defined $coversheet );

	# check whether there is an existing covered version and whether it needs to be regenerated
	my $current_cs_id = $doc->get_value( 'coversheetid' ) || -1; # coversheet used to cover document
	my $coverdoc; # existing covered version

	if( $coversheet->get_id == $current_cs_id )
	{
		# get the covered version of the document
		$coverdoc = $coversheet->get_coversheet_doc( $doc );
	}

	if( defined $coverdoc )
	{
		# return the covered version
		$coverdoc->set_value( "security", $doc->get_value( "security" ) );
		$request->pnotes( document => $coverdoc );
		$request->pnotes( dataobj => $coverdoc );

		# Only update request filename to coverdoc's filename if it is defined and the document filename matches that used in the request.  
		# If the document filename does not match that used in the request, then not updating the filename will mean requests with a
		# spurious filename will get a 404 error (same as uncoversheeted documents) rather than returning the document under a spurious filename.
		$request->pnotes( filename => $coverdoc->get_main ) if defined $coverdoc->get_main && defined $doc->get_main && $filename eq $doc->get_main;
	}

	# return the uncovered document

	return EP_TRIGGER_DONE;

}, priority => 100 );

$c->add_dataset_trigger( "eprint", EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub {

	my( %params, %changed ) = @_;

	my $session = $params{repository};
	my $eprint = $params{dataobj};

	my $coversheets_dirty = $eprint->get_value( "coversheets_dirty" );

	foreach my $doc ( $eprint->get_all_documents )
	{
		my $coversheet = EPrints::DataObj::Coversheet->search_by_doc( $doc );

		if( $coversheet )
		{
			my $hash = EPrints::DataObj::Coversheet->calculate_coverdata_hash( $session, $eprint, $doc );

			my $has_error = $doc->get_value( "coversheet_error" );
			my $doc_hash = $doc->get_value( "coverdata_hash" );

			if( !$has_error )
			{
				# Check the hash of the eprint tag data.

				if(( !defined( $doc_hash ))||( $hash ne $doc_hash ))
				{
					$coversheets_dirty = "TRUE";
				}

				# Check the hash of the coversheet template files.

				my $coversheet_frontfile_hash = $coversheet->get_value( "frontfile_hash" );
				my $coversheet_backfile_hash  = $coversheet->get_value( "backfile_hash"  );

				my $document_frontfile_hash = $doc->get_value( "coversheet_frontfile_hash" );
				my $document_backfile_hash  = $doc->get_value( "coversheet_backfile_hash"  );

				if( defined( $coversheet_frontfile_hash ))
				{
					if( !defined( $document_frontfile_hash ) || ( $document_frontfile_hash ne $coversheet_frontfile_hash ))
					{
						$coversheets_dirty = "TRUE";
					}
				}

				if( defined( $coversheet_backfile_hash ))
				{
					if( !defined( $document_backfile_hash ) || ( $document_backfile_hash ne $coversheet_backfile_hash ))
					{
						$coversheets_dirty = "TRUE";
					}
				}
			}
		}
	}

	$eprint->set_value( "coversheets_dirty", $coversheets_dirty );
	
}, priority => 500 );
