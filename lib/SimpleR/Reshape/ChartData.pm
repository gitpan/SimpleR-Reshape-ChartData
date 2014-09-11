# ABSTRACT: conv data for chart 
package SimpleR::Reshape::ChartData;

require Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(
read_chart_data_dim2
read_chart_data_dim3
read_chart_data_dim3_horizon
read_chart_data_dim3_scatter
);

our $VERSION = 0.03;

use SimpleR::Reshape qw/read_table melt/;
use SimpleR::Stat qw/uniq_arrayref conv_arrayref_to_hash/;

sub read_chart_data_dim3_scatter {
    my ( $d, %opt ) = @_;

    my $r = read_table( $d, %opt );
    my $h = conv_arrayref_to_hash( $r, [ $opt{legend}, $opt{label} ], $opt{data} );

    my @legend_fields = $opt{legend_sort} ? @{ $opt{legend_sort} } : sort keys(%$h);
    my $label_uniq = uniq_arrayref([ map { keys(%{$h->{$_}}) } @legend_fields ]);
    my @label_fields = $opt{label_sort} ? @{ $opt{label_sort} } : sort @$label_uniq;

    my @chart_data = map { 
    my $r = $h->{$_};
    my @k=keys %$r;
    my @d = map { $r->{$_} } @k;
     [ \@k, \@d ] 
    } 
    @legend_fields;
    for my $c (@chart_data) {
        $_ ||= 0 for @$c;
    }

    return (
        \@chart_data,
        label  => \@label_fields,
        legend => \@legend_fields,
    );
}

sub read_chart_data_dim3_horizon {
    my ( $d, %opt ) = @_;
    my $r = read_table( $d, %opt );
    $xr = melt( $r, id => $opt{label}, measure => $opt{legend}, names=> $opt{names}, return_arrayref=> 1,  );

    return read_chart_data_dim3( $xr, 
        label => [0], 
        legend => [1], 
        data=> [2] ,
        legend_sort => $opt{legend_sort}, 
        label_sort => $opt{label_sort}, 
    );
}

sub read_chart_data_dim2 {
    my ($d, %opt) = @_;

    $opt{legend} = $opt{label};
    $opt{legend_sort} = $opt{label_sort};
    my ($res, %res_opt) = read_chart_data_dim3($d, %opt); 
    my @data = map { $res->[$_][$_] } (0 .. $#$res);

    return (\@data, %res_opt);
}

sub read_chart_data_dim3 {
    my ( $d, %opt ) = @_;

    my $r = read_table( $d, %opt );
    my $h = conv_arrayref_to_hash( $r, [ $opt{legend}, $opt{label} ], $opt{data} );


    my @legend_fields = $opt{legend_sort} ? @{ $opt{legend_sort} } : sort keys(%$h);
    my $label_uniq = uniq_arrayref([ map { keys(%{$h->{$_}}) } @legend_fields ]);
    my @label_fields = $opt{label_sort} ? @{ $opt{label_sort} } : @$label_uniq;

    my @chart_data = map { [ @{ $h->{$_} }{@label_fields} ] } @legend_fields;
    for my $c (@chart_data) {
        $_ ||= 0 for @$c;
    }

    return (
        \@chart_data,
        label  => \@label_fields,
        legend => \@legend_fields,
    );
}

1;


