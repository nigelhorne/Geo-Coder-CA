#!perl -w

use warnings;
use strict;
use Test::LWP::UserAgent;
use Test::Number::Delta within => 1e-2;
use Test::Most tests => 10;
use Test::Carp;

BEGIN {
	use_ok('Geo::Coder::CA');
}

US: {
	SKIP: {
		skip 'Test requires Internet access', 9 unless(-e 't/online.enabled');

		my $geocoder = new_ok('Geo::Coder::CA');
		my $location = $geocoder->geocode('1600 Pennsylvania Avenue NW, Washington DC');
		delta_ok($location->{latt}, 38.90);
		delta_ok($location->{longt}, -77.04);

		$location = $geocoder->geocode(location => '1600 Pennsylvania Avenue NW, Washington DC, USA');
		delta_ok($location->{latt}, 38.90);
		delta_ok($location->{longt}, -77.04);

		my $address = $geocoder->reverse_geocode('38.9,-77.04');
		is($address->{'prov'}, 'DC', 'test reverse');

		my $ua = new_ok('Test::LWP::UserAgent');
		$ua->map_response('geocoder.ca', new_ok('HTTP::Response' => [ '500' ]));

		$geocoder->ua($ua);

		sub f {
			$location = $geocoder->geocode(location => '1600 Pennsylvania Avenue NW, Washington DC, USA');
		};
		does_croak_that_matches(\&f, qr/^geocoder.ca API returned error: 500/);
	}
}
