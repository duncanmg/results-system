    #!/usr/bin/perl

    use DBI;

    my $dbh = DBI->connect("dbi:SQLite:rs.db") || die "Cannot connect: $DBI::errstr";

