# Bazaar Configuration

$c->{plugins}{"Convert::AddCoversheet"}{params}{disable} = 0;
$c->{plugins}{"Event::AddCoversheet"}{params}{disable} = 0;
$c->{plugins}{"Screen::Coversheet::Activate"}{params}{disable} = 0;
$c->{plugins}{"Screen::Coversheet::Deprecate"}{params}{disable} = 0;
$c->{plugins}{"Screen::Coversheet::Edit"}{params}{disable} = 0;
$c->{plugins}{"Screen::Coversheet::New"}{params}{disable} = 0;
$c->{plugins}{"Screen::EPMC::Coversheet"}{params}{disable} = 0;



# Stores the id of the Coversheet Dataobj that was used to generated the CS'ed document
push @{$c->{fields}->{document}},
        {
                name => 'coversheetid',
                type => 'int',
                sql_index => 0,
        };

push @{$c->{fields}->{document}},
        {
                name => 'coverdata_hash',
                type => 'text',
                sql_index => 0,
        };

push @{$c->{fields}->{document}},
        {
                name => 'coversheet_frontfile_hash',
                type => 'text',
                sql_index => 0,
        };

push @{$c->{fields}->{document}},
        {
                name => 'coversheet_backfile_hash',
                type => 'text',
                sql_index => 0,
        };

# The coversheet dirty flag is used to signal the check_coversheets script to
# regenerate coversheets for this eprint. This bit gets set every time the
# eprint is committed and the metadata has changed.

push @{$c->{fields}->{eprint}},
        {
                name => 'coversheets_dirty',
                type => 'boolean',
                sql_index => 0,
        };

# The coversheet error flag is used to signal that there were errors during
# coversheet generation.

push @{$c->{fields}->{document}},
        {
                name => 'coversheet_error',
                type => 'boolean',
                sql_index => 0,
        };

# Where the coversheets are stored:
$c->{coversheet}->{path_suffix} = '/coversheets';
$c->{coversheet}->{path} = $c->{archiveroot}.'/cfg/static/coversheets';
$c->{coversheet}->{url} = $c->{base_url}.'/coversheets';

# Ghostscript command to stitch the pdfs
#$c->{gs_pdf_stich_cmd} = "gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=";
$c->{gs_pdf_stich_cmd} = $c->{base_path} . "/ingredients/coversheets/bin/stitchPDFs ";


# Fields used for applying coversheets
$c->{license_application_fields} = [ "type" ];

#new permissions for coversheet toolkit
$c->{roles}->{"coversheet-editor"} =
[
	"coversheet/destroy",
        "coversheet/write",
        "coversheet/activate",
        "coversheet/deprecate",
        "coversheet/view",
];

push @{$c->{user_roles}->{editor}}, 'coversheet-editor';
push @{$c->{user_roles}->{admin}}, 'coversheet-editor';
push @{$c->{user_roles}->{local_admin}}, 'coversheet-editor';

# Tags may be defined locally, see Plugin/Convert/AddCoversheet.pm
# $c->{coversheet}->{tags} = {};

