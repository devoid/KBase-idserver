package Bio::KBase::IDServer::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

=head1 NAME

Bio::KBase::IDServer::Client

=head1 DESCRIPTION



=cut

sub new
{
    my($class, $url) = @_;

    my $self = {
	client => Bio::KBase::IDServer::Client::RpcClient->new,
	url => $url,
    };
    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);

    return bless $self, $class;
}




=head2 $result = kbase_ids_to_external_ids(ids)

Given a set of KBase identifiers, look up the associated external identifiers.
If no external ID is associated with the KBase id, no entry will be present in the return.

=cut

sub kbase_ids_to_external_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function kbase_ids_to_external_ids (received $n, expecting 1)");
    }
    {
	my($ids) = @args;

	my @_bad_arguments;
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to kbase_ids_to_external_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'kbase_ids_to_external_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.kbase_ids_to_external_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'kbase_ids_to_external_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method kbase_ids_to_external_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'kbase_ids_to_external_ids',
				       );
    }
}



=head2 $result = external_ids_to_kbase_ids(external_db, ext_ids)

Given a set of external identifiers, look up the associated KBase identifiers.
If no KBase ID is associated with the external id, no entry will be present in the return.

=cut

sub external_ids_to_kbase_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function external_ids_to_kbase_ids (received $n, expecting 2)");
    }
    {
	my($external_db, $ext_ids) = @args;

	my @_bad_arguments;
        (!ref($external_db)) or push(@_bad_arguments, "Invalid type for argument 1 \"external_db\" (value was \"$external_db\")");
        (ref($ext_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"ext_ids\" (value was \"$ext_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to external_ids_to_kbase_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'external_ids_to_kbase_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.external_ids_to_kbase_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'external_ids_to_kbase_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method external_ids_to_kbase_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'external_ids_to_kbase_ids',
				       );
    }
}



=head2 $result = register_ids(prefix, db_name, ids)

Register a set of identifiers. All will be assigned identifiers with the given
prefix.

If an external ID has already been registered, the existing registration will be returned instead 
of a new ID being allocated.

=cut

sub register_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function register_ids (received $n, expecting 3)");
    }
    {
	my($prefix, $db_name, $ids) = @args;

	my @_bad_arguments;
        (!ref($prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"prefix\" (value was \"$prefix\")");
        (!ref($db_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"db_name\" (value was \"$db_name\")");
        (ref($ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ids\" (value was \"$ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to register_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'register_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.register_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'register_ids',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method register_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'register_ids',
				       );
    }
}



=head2 $result = allocate_id_range(kbase_id_prefix, count)

Allocate a set of identifiers. This allows efficient registration of a large
number of identifiers (e.g. several thousand features in a genome).

The return is the first identifier allocated.

=cut

sub allocate_id_range
{
    my($self, @args) = @_;

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function allocate_id_range (received $n, expecting 2)");
    }
    {
	my($kbase_id_prefix, $count) = @args;

	my @_bad_arguments;
        (!ref($kbase_id_prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"kbase_id_prefix\" (value was \"$kbase_id_prefix\")");
        (!ref($count)) or push(@_bad_arguments, "Invalid type for argument 2 \"count\" (value was \"$count\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to allocate_id_range:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'allocate_id_range');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.allocate_id_range",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'allocate_id_range',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method allocate_id_range",
					    status_line => $self->{client}->status_line,
					    method_name => 'allocate_id_range',
				       );
    }
}



=head2 $result = register_allocated_ids(prefix, db_name, assignments)

Register the mappings for a set of external identifiers. The
KBase identifiers used here were previously allocated using allocate_id_range.

Does not return a value.

=cut

sub register_allocated_ids
{
    my($self, @args) = @_;

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function register_allocated_ids (received $n, expecting 3)");
    }
    {
	my($prefix, $db_name, $assignments) = @args;

	my @_bad_arguments;
        (!ref($prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"prefix\" (value was \"$prefix\")");
        (!ref($db_name)) or push(@_bad_arguments, "Invalid type for argument 2 \"db_name\" (value was \"$db_name\")");
        (ref($assignments) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 3 \"assignments\" (value was \"$assignments\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to register_allocated_ids:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'register_allocated_ids');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.register_allocated_ids",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'register_allocated_ids',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method register_allocated_ids",
					    status_line => $self->{client}->status_line,
					    method_name => 'register_allocated_ids',
				       );
    }
}



=head2 $result = kbase_ids_with_prefix(prefix)

Given an ID prefix, return the set of KBase ids that match that prefix.

=cut

sub kbase_ids_with_prefix
{
    my($self, @args) = @_;

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function kbase_ids_with_prefix (received $n, expecting 1)");
    }
    {
	my($prefix) = @args;

	my @_bad_arguments;
        (!ref($prefix)) or push(@_bad_arguments, "Invalid type for argument 1 \"prefix\" (value was \"$prefix\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to kbase_ids_with_prefix:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'kbase_ids_with_prefix');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "IDServerAPI.kbase_ids_with_prefix",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'kbase_ids_with_prefix',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method kbase_ids_with_prefix",
					    status_line => $self->{client}->status_line,
					    method_name => 'kbase_ids_with_prefix',
				       );
    }
}




package Bio::KBase::IDServer::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


1;
