#!/usr/bin/perl

# Author Code: Osvaldo Yañez Osses

use strict;
use warnings;
use Benchmark;
use File::Copy;
#
# install: cpan Math::Matrix
use Math::Matrix;
# install: cpan Parallel::ForkManager
use Parallel::ForkManager;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# global variables
#
# # #
# check similarity
my $threshold_duplicate = 0.007;
# number of process
my $nprocess = 80;

# # #
# Path for software mopac 
my $path_bin_mopac = "/opt/mopac/MOPAC2016.exe";

# # # 
# convergence criteria Lammps
my $criteria_lammps = "1e-06";
# specify the maximum numer of steps 
my $steps_lammps    = "100";
my $path_bin_lammps = "lmp_mpi.exe";

# # #
# molecular mechanics
# convergence criteria
my $criteria            = "1e-20";
# specify the maximum numer of steps 
my $steps               = "10";
# convergence algorithm (conjugate gradients algorithm,-cg),
# (steepest descent algorithm,-sd) y (Newton2Num linesearch,-newton)
my $conv_algorithm      = "-sd";
#
#
my $num_atoms_xyz;
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



##############
# Hashs 
my $other_element = 0.8;
my %Atomic_radii = ( 'H'  => '0.4', 'He' => '0.3', 'Li' => '1.3', 'Be' => '0.9', 
                     'B'  => '0.8', 'C'  => '0.8', 'N'  => '0.8', 'O'  => '0.7', 
					 'F'  => '0.7', 'Ne' => '0.7', 'Na' => '1.5', 'Mg' => '1.3', 
					 'Al' => '1.2', 'Si' => '1.1', 'P'  => '1.1', 'S'  => '1.0', 
					 'Cl' => '1.0', 'Ar' => '1.0', 'K'  => '2.0', 'Ca' => '1.7', 
					 'Sc' => '1.4', 'Ti' => '1.4', 'V'  => '1.3', 'Cr' => '1.3', 
					 'Mn' => '1.4', 'Fe' => '1.3', 'Co' => '1.3', 'Ni' => '1.2', 
					 'Cu' => '1.4', 'Zn' => '1.3', 'Ga' => '1.3', 'Ge' => '1.2', 
					 'As' => '1.2', 'Se' => '1.2', 'Br' => '1.1', 'Kr' => '1.1', 
					 'Rb' => '2.1', 'Sr' => '1.9', 'Y'  => '1.6', 'Zr' => '1.5', 
					 'Nb' => '1.4', 'Au' => '1.4' );

my %Atomic_number = ( '89'  => 'Ac', '13'  => 'Al', '95'  => 'Am', '51'  => 'Sb',	
	                  '18'  => 'Ar', '33'  => 'As', '85'  => 'At', '16'  => 'S',  
					  '56'  => 'Ba', '4'   => 'Be', '97'  => 'Bk', '83'  => 'Bi',	
                      '107' => 'Bh', '5'   => 'B', 	'35'  => 'Br', '48'  => 'Cd',	
	                  '20'  => 'Ca', '98'  => 'Cf',	'6'   => 'C',  '58'  => 'Ce',	
	                  '55'  => 'Cs', '17'  => 'Cl',	'27'  => 'Co', '29'  => 'Cu',	
	                  '24'  => 'Cr', '96'  => 'Cm', '110' => 'Ds', '66'  => 'Dy',
	                  '105' => 'Db', '99'  => 'Es', '68'  => 'Er', '21'  => 'Sc',	
	                  '50'  => 'Sn', '38'  => 'Sr', '63'  => 'Eu', '100' => 'Fm',	
	                  '9'   => 'F',  '15'  => 'P',  '87'  => 'Fr', '64'  => 'Gd',	
	                  '31'  => 'Ga', '32'  => 'Ge', '72'  => 'Hf', '108' => 'Hs',	
                      '2'   => 'He', '1'   => 'H',  '26'  => 'Fe', '67'  => 'Ho',	
					  '49'  => 'In', '53'  => 'I',  '77'  => 'Ir', '70'  => 'Yb',
					  '39'  => 'Y',  '36'  => 'Kr', '57'  => 'La', '103' => 'Lr',	
					  '3'   => 'Li', '71'  => 'Lu', '12'  => 'Mg', '25'  => 'Mn',	
                      '109' => 'Mt', '101' => 'Md', '80'  => 'Hg', '42'  => 'Mo',	
					  '60'  => 'Nd', '10'  => 'Ne', '93'  => 'Np', '41'  => 'Nb',	
					  '28'  => 'Ni', '7'   => 'N',  '102' => 'No', '79'  => 'Au',	
					  '76'  => 'Os', '8'   => 'O', 	'46'  => 'Pd', '47'  => 'Ag',	
					  '78'  => 'Pt', '82'  => 'Pb',	'94'  => 'Pu', '84'  => 'Po',	
					  '19'  => 'K',  '59'  => 'Pr', '61'  => 'Pm', '91'  => 'Pa',	
					  '88'  => 'Ra', '86'  => 'Rn', '75'  => 'Re', '45'  => 'Rh',	
					  '37'  => 'Rb', '44'  => 'Ru', '104' => 'Rf', '62'  => 'Sm',
					  '106' => 'Sg', '34'  => 'Se', '14'  => 'Si', '11'  => 'Na',
					  '81'  => 'Tl', '73'  => 'Ta', '43'  => 'Tc', '52'  => 'Te',	
					  '65'  => 'Tb', '22'  => 'Ti', '90'  => 'Th', '69'  => 'Tm',	
					  '112' => 'Uub','116' => 'Uuh','111' => 'Uuu','118' => 'Uuo',	
					  '115' => 'Uup','114' => 'Uuq','117' => 'Uus','113' => 'Uut',
					  '92'  => 'U',  '23'  => 'V',  '74'  => 'W',  '54'  => 'Xe',
                      '30'  => 'Zn', '40'  => 'Zr' );

my %Atomic_mass   = ( 'H'   => '1.0079'  ,'He' => '4.003'   ,'Li'  => '6.941'   ,'Be'  => '9.0122',
                      'B'   => '10.811'  ,'C'  => '12.018'  ,'N'   => '14.0067' ,'O'   => '15.9994', 
                      'F'   => '18.998'  ,'Ne' => '20.179'  ,'Na'  => '22.9897' ,'Mg'  => '24.305',
                      'Al'  => '26.981'  ,'Si' => '28.085'  ,'P'   => '30.9738' ,'Cl'  => '35.453',
                      'K'   => '39.098'  ,'Ar' => '39.948'  ,'Ca'  => '40.078'  ,'Sc'  => '44.9559',
                      'Ti'  => '47.867'  ,'V'  => '50.942'  ,'Cr'  => '51.9961' ,'Mn'  => '54.938',
                      'Fe'  => '55.845'  ,'Ni' => '58.693'  ,'Co'  => '58.9332' ,'Cu'  => '63.546',
                      'Zn'  => '65.390'  ,'Ga' => '69.723'  ,'Ge'  => '72.64'   ,'As'  => '74.9216', 
                      'Se'  => '78.960'  ,'Br' => '79.904'  ,'Kr'  => '83.8'    ,'Rb'  => '85.4678', 
                      'Sr'  => '87.620'  ,'Y'  => '88.906'  , 'Zr' => '91.224'  ,'Nb'  => '92.9064',
                      'Mo'  => '95.940'  ,'Tc' => '98.000'  ,'Ru'  => '101.07'  ,'Rh'  => '102.9055',
                      'Pd'  => '106.420' ,'Ag' => '107.868' , 'Cd' => '112.411' ,'In'  => '114.818',
                      'Sn'  => '118.710' ,'Sb' => '121.760' ,'I'   => '126.9045','Te'  => '127.6',
                      'Xe'  => '131.290' ,'Cs' => '132.906' ,'Ba'  => '137.327' ,'La'  => '138.9055',
                      'Ce'  => '140.116' ,'Pr' => '140.908' ,'Nd'  => '144.24'  ,'Pm'  => '145',
                      'Sm'  => '150.360' ,'Eu' => '151.964' ,'Gd'  => '157.25'  ,'Tb'  => '158.9253' ,
                      'Dy'  => '162.500' ,'Ho' => '164.930' , 'Er' => '167.259' ,'Tm'  => '168.9342',
                      'Yb'  => '173.040' ,'Lu' => '174.967' ,'Hf'  => '178.49'  ,'Ta'  => '180.9479',
                      'W'   => '183.840' ,'Re' => '186.207' ,'Os'  => '190.23'  ,'Ir'  => '192.217',
					  'Pt'  => '195.078' ,'Au' => '196.967' ,'Hg'  => '200.59'  ,'Tl'  => '204.3833',
                      'Pb'  => '207.200' ,'Bi' => '208.980' ,'Po'  => '209'     ,'At'  => '210',
					  'Rn'  => '222.000' ,'Fr' => '223.000' ,'Ra'  => '226'     ,'Ac'  => '227',
					  'Pa'  => '231.035' ,'Th' => '232.038' ,'Np'  => '237'     ,'U'   => '238.0289',
					  'Am'  => '243.000' ,'Pu' => '244'     ,'Cm'  => '247'     ,'Bk'  => '247', 
					  'Cf'  => '251.000' ,'Es' => '252'     ,'Fm'  => '257'     ,'Md'  => '258',
					  'No'  => '259.000' ,'Rf' => '261'     ,'Lr'  => '262'     ,'Db'  => '262',
					  'Bh'  => '264.000' ,'Sg' => '266'     ,'Mt'  => '268'     ,'Hs'  => '277' );
###################################
# Verification
sub verification{
	my ($a1, $a2, $dist)=@_;
	# hash values	
	my $v1  = $Atomic_radii{$a1} || $other_element; 
	my $v2  = $Atomic_radii{$a2} || $other_element;
	my $sum = $v1 + $v2;  
	my $resultado;
	# steric effects if radio1+radio2 < distance
	if($dist <= $sum){
		# Steric problem	
		$resultado = 1; 
	}else{
		$resultado = 0;
	}
	return $resultado;
}
###################################
# Steric Impediment
sub steric_impediment {
	# array are send by reference
	my ($frag_1,$frag_2) = @_;
	#
	# reference arrays	
	#	my @coords1 = @{$frag_1}; 
	#	my @coords2 = @{$frag_2};
	# get size
	my $final_trial = 0;
	my $resultado   = 0;
	#w
	foreach my $key (sort(keys %$frag_2)) {
		my @coords1 = @{%$frag_1{$key}};
		my @coords2 = @{%$frag_2{$key}};
		# 
		for (my $i=0; $i < scalar(@coords1);$i++){
			for (my $j=0; $j < scalar(@coords2); $j++){
				my ($atom_1,$axis_x_1,$axis_y_1,$axis_z_1) = split '\s+', $coords1[$i];
				my ($atom_2,$axis_x_2,$axis_y_2,$axis_z_2) = split '\s+', $coords2[$j];
				my $distance    = Euclidean_distance($axis_x_1,$axis_y_1,$axis_z_1,$axis_x_2,$axis_y_2,$axis_z_2);
				$final_trial = $final_trial + verification($atom_1,$atom_2,$distance);
				if( $final_trial ==	 1 ) {
					$resultado = 1;
					last;
				}
			}
		}
	}
	# verify for steric impediment, 1 yes, 0 no;
	return $resultado;				
}
###################################
# Optimize the geometry, minimize the energy for a molecule (Open-Babel)
sub OptMMBabel {
	#
	my $XYZInput  = $_[0];
	my $XYZOutput = $_[1];
	my $relax_FF  = $_[2];
	# Parametros
	# convergence criteria
	my $criteria   = $_[3];
	# select a forcefield MMFF94s,MMFF94,ghemical,gaff,UFF
	my $forcefield = $relax_FF;
	# specify the maximum numer of steps 
	my $steps      = $_[4];
	my $conv_alg   = $_[5];
	#
	system ("obminimize -oxyz -ff $forcefield $conv_alg -n $steps -c $criteria $XYZInput >$XYZOutput 2>tmp.dat");
	#
	open(OUT,"$XYZOutput") or die "Unable to open fragment file: $XYZOutput (subrutine)";
	my @FragLines = <OUT>;
	close (OUT);
	#
	open(ENERGY,"tmp.dat") or die "Unable to open fragment file: tmp.dat (subrutine)";
	my @FragLines_e = <ENERGY>;
	close (ENERGY);
#	print "obminimize -ff $forcefield -sd -n $steps -c $criteria $XYZInput >$XYZOutput \n";
	my $countHead = 0;
	my $concate   = '';	
	while (my $Fline = shift (@FragLines)) {
		chomp ($Fline);	
		#
		if ($Fline =~ /WARNING/){
		} else {
			if ($countHead > 1 ){
				$concate.="$Fline\n";
			}
			$countHead++;
		}		
	}
	#
	my $count = 0;
	my $flag;
	my $mm_energy;
	foreach my $Flines (@FragLines_e) {
		chomp ($Flines);	
		# Time: 5 seconds. Iterations per second: 4000.2
		# STEP n       E(n)         E(n-1)
		if ( ($Flines=~/STEP/gi ) && ($Flines=~/E\(n\)/gi ) && ($Flines=~/E\(n-1\)/gi ) ){
			$flag = $count + 2;
			$mm_energy = $FragLines_e[$flag];
		}
		$count++;		
	}
	my @words = split '\s+', $mm_energy;
	my @array = ($concate,$words[2]);
	return @array;
}
###################################
# Input file gaussian 
sub G03Input {
	#
	my $filebase     = $_[0];
	my $G03Input     = "$filebase.com";
	my $Header       = $_[1];
	my $ncpus        = $_[2];
	my $mem          = $_[3];
	my $Charge       = $_[4];
	my $Multiplicity = $_[5];
	my $coordsMM     = $_[6];
	my $iteration    = $_[7];
	#
	open (COMFILE, ">$G03Input");
	#print COMFILE "%chk=$filebase.chk\n";
	if ( $ncpus > 0 ) {
		print COMFILE "%NProc=$ncpus\n";
	}	
	(my $word_nospaces = $mem) =~ s/\s//g;
	print COMFILE "%mem=$word_nospaces"."GB\n";
	print COMFILE "# $Header \n";
	print COMFILE "\nKick job $iteration\n";
	print COMFILE "\n";
	print COMFILE "$Charge $Multiplicity\n";
	print COMFILE "$coordsMM\n";
	print COMFILE "\n";
	close COMFILE;
}
###################################
# Input file Mopac
sub MopacInput {
	#
	my $filebase     = $_[0];
	my $coordsMM     = $_[1];
	my $MopacInput   = "$filebase.mop";
	my $iteration    = $_[2];
	my $Headerfile   = $_[3];
	my $Charge       = $_[4];
	my $Multiplicity = $_[5];
	#
	my $mem          = $_[7];
	#
	my $tmp   = 1;
	my @words = split (/\n/,$coordsMM);
	#
	open (COMFILE, ">$MopacInput");
	#
	my $word;
	# Spin multiplicity:
	if ( $Multiplicity == 0 ) { $word = "NONET"   };			
	# singlet	- 0 unpaired electrons
	if ( $Multiplicity == 1 ) { $word = "SINGLET" };
	# doublet	- 1 unpaired electrons
	if ( $Multiplicity == 2 ) { $word = "DOUBLET" };
	# triplet	- 2 unpaired electrons
	if ( $Multiplicity == 3 ) { $word = "TRIPLET" };
	# quartet	- 3 unpaired electrons
	if ( $Multiplicity == 4 ) { $word = "QUARTET" };
	# quintet	- 4 unpaired electrons			
	if ( $Multiplicity == 5 ) { $word = "QUINTET" };
	# sextet	- 5 unpaired electrons
	if ( $Multiplicity == 6 ) { $word = "SEXTET"  };
	# septet	- 6 unpaired electrons
	if ( $Multiplicity == 7 ) { $word = "SEPTET"  };
	# octet	- 7 unpaired electrons
	if ( $Multiplicity == 8 ) { $word = "OCTET"   };
	#
	my $ncpus        = ($_[6] * 2);
	if ( $ncpus == 0 ) {
		print COMFILE "$Headerfile $word CHARGE=$Charge";
	} else {
		# The maximum number of threads is normally equal to the number of cores, 
		# even if each core supports two threads.
		# In the special case of THREADS=1, parallelization is switched off.
		print COMFILE "$Headerfile $word CHARGE=$Charge THREADS=$ncpus";
	}	
	print COMFILE "\n";
	print COMFILE "Kick job $iteration\n";
	print COMFILE "\n";	
	foreach my $i (@words){
		my @axis    = split (" ",$i);
		#
		my $label  = $axis[0];  
		my $axis_x = $axis[1];
		my $axis_y = $axis[2];
		my $axis_z = $axis[3];
		#
		print COMFILE "$label\t$axis_x\t$tmp\t$axis_y\t$tmp\t$axis_z\t$tmp\n";
	}
	print COMFILE "\n";
	print COMFILE "\n";
	close (COMFILE);
	#
	return $MopacInput;
}
###################################
# Generation of random co-ordinates
sub gen_xyz {
	my ($Box_x, $Box_y, $Box_z) = @_;
	# generate a random number in perl in the range box size
	my $lower_limit_x = ($Box_x * -1);
	my $upper_limit_x = $Box_x;
	my $lower_limit_y = ($Box_y * -1);
	my $upper_limit_y = $Box_y;
	my $lower_limit_z = ($Box_z * -1);
	my $upper_limit_z = $Box_z;
	#
	my $x = (rand($upper_limit_x-$lower_limit_x) + $lower_limit_x);
	my $y = (rand($upper_limit_y-$lower_limit_y) + $lower_limit_y);
	my $z = (rand($upper_limit_z-$lower_limit_z) + $lower_limit_z);
	#
	my $x_coord = sprintf '%.6f', $x;
	my $y_coord = sprintf '%.6f', $y;
	my $z_coord = sprintf '%.6f', $z;
	my @coords  = ($x_coord, $y_coord, $z_coord);
	return @coords;
}
###################################
# Phi, theta, psi
sub gen_ptp {
	my $pi     = 3.14159265;
	my $phi    = sprintf '%.6f', rand()*2*$pi;
	my $theta  = sprintf '%.6f', rand()*2*$pi;
	my $psi    = sprintf '%.6f', rand()*2*$pi;
	my @angles = ($phi, $theta, $psi);
	return @angles;
}
###################################
# Compute the center of mass
sub measure_center {
	my ($coord_x,$coord_y,$coord_z) = @_;
	my $num_data = scalar (@{$coord_x});
	my @array  = ();
	my $weight = 1;
	# variable sum
	my $sum_weight = 0;
	my $sum_x = 0;
	my $sum_y = 0;
	my $sum_z = 0;
	for ( my $j = 0 ; $j < $num_data ; $j = $j + 1 ){
		$sum_weight+= $weight;
		$sum_x+= $weight * @$coord_x[$j];
		$sum_y+= $weight * @$coord_y[$j];
		$sum_z+= $weight * @$coord_z[$j];		
	}
	my $com_x = $sum_x / $sum_weight;
	my $com_y = $sum_y / $sum_weight;
	my $com_z = $sum_z / $sum_weight;
	# array
	@array = ($com_x,$com_y,$com_z);
	# return array	
	return @array;
}
###################################
# Returns the additive inverse of v(-v)
sub vecinvert {
	my ($center_mass) = @_;
	my @array         = ();
	foreach my $i (@$center_mass) {
		my $invert        = $i * -1;
		$array[++$#array] = $invert; 
	}	
	# return array	
	return @array;
}
###################################
# Returns the vector sum of all the terms.
sub vecadd {
	my ($coord_x,$coord_y,$coord_z,$vecinvert_cm ) = @_;
	my $num_data = scalar (@{$coord_x});
	my @array   = ();
	my $sum_coord_x;
	my $sum_coord_y;
	my $sum_coord_z;
	# array 
	my @array_x = ();
	my @array_y = ();
	my @array_z = ();
	for ( my $i = 0 ; $i < $num_data ; $i = $i + 1 ){	
		$sum_coord_x = @$coord_x[$i]+@$vecinvert_cm[0] ; 
		$sum_coord_y = @$coord_y[$i]+@$vecinvert_cm[1] ;
		$sum_coord_z = @$coord_z[$i]+@$vecinvert_cm[2] ;
		# save array
		$array_x[++$#array_x] = $sum_coord_x;
		$array_y[++$#array_y] = $sum_coord_y;
		$array_z[++$#array_z] = $sum_coord_z;
	}
	@array = ( [@array_x], 
              [@array_y], 
              [@array_z] ); 
	# return array	
	return @array;
}
###################################
# Drawing a box around a molecule 
sub box_molecule {
	my ($coordsmin, $coordsmax) = @_;
	#
	my $minx = @$coordsmin[0];
	my $maxx = @$coordsmax[0];
	my $miny = @$coordsmin[1];
	my $maxy = @$coordsmax[1];
	my $minz = @$coordsmin[2];
	my $maxz = @$coordsmax[2];
	# raw the lines
	
	my $filename = 'BOX_kick.vmd';
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";	
	print $fh "draw delete all\n";
	print $fh "draw materials off\n";
	print $fh "draw color green\n";
	#
	print $fh "draw line \"$minx $miny $minz\" \"$maxx $miny $minz\" \n";
	print $fh "draw line \"$minx $miny $minz\" \"$minx $maxy $minz\" \n";
	print $fh "draw line \"$minx $miny $minz\" \"$minx $miny $maxz\" \n";
	#
	print $fh "draw line \"$maxx $miny $minz\" \"$maxx $maxy $minz\" \n";
	print $fh "draw line \"$maxx $miny $minz\" \"$maxx $miny $maxz\" \n";
	#
	print $fh "draw line \"$minx $maxy $minz\" \"$maxx $maxy $minz\" \n";
	print $fh "draw line \"$minx $maxy $minz\" \"$minx $maxy $maxz\" \n";
	#
	print $fh "draw line \"$minx $miny $maxz\" \"$maxx $miny $maxz\" \n";
	print $fh "draw line \"$minx $miny $maxz\" \"$minx $maxy $maxz\" \n";
	#
	print $fh "draw line \"$maxx $maxy $maxz\" \"$maxx $maxy $minz\" \n";
	print $fh "draw line \"$maxx $maxy $maxz\" \"$minx $maxy $maxz\" \n";
	print $fh "draw line \"$maxx $maxy $maxz\" \"$maxx $miny $maxz\" \n";
	close $fh;
}					   
###################################
# Automatic box size
sub automatic_box_size {
	my ($input_array) = @_;
	my $sum = 0;
	#
	foreach my $i (@{$input_array}) {
		my $radii_val;
		if ( exists $Atomic_radii{$i} ) {
			# exists
			$radii_val = $Atomic_radii{$i};
		} else {
			# not exists
			$radii_val = $other_element ;
		}
		$sum+=$radii_val;
	}
	return $sum;
}
###################################
# Keywords Errors
sub errors_config {
	my ($data) = @_;
	my $bolean = 1;
	if ( ( @$data[0]  =~/kick_numb_input/gi )  ){ } else { print "ERROR Correct Keywords: kick_numb_input\n";  $bolean = 0;};
	if ( ( @$data[1]  =~/box_size/gi )         ){ } else { print "ERROR Correct Keywords: box_size\n";         $bolean = 0;};
	if ( ( @$data[2]  =~/chemical_formula/gi ) ){ } else { print "ERROR Correct Keywords: chemical_formula\n"; $bolean = 0;};
	if ( ( @$data[3]  =~/fragments/gi )        ){ } else { print "ERROR Correct Keywords: fragments\n";        $bolean = 0;};
	if ( ( @$data[4]  =~/core_mem/gi )         ){ } else { print "ERROR Correct Keywords: core_mem\n";         $bolean = 0;};
	if ( ( @$data[5]  =~/charge_multi/gi)      ){ } else { print "ERROR Correct Keywords: charge_multi\n";     $bolean = 0;};
	if ( ( @$data[6]  =~/header/gi)            ){ } else { print "ERROR Correct Keywords: header\n";           $bolean = 0;};
	if ( ( @$data[7]  =~/fragm_fix/gi)         ){ } else { print "ERROR Correct Keywords: fragm_fix\n";        $bolean = 0;};	
	if ( ( @$data[8]  =~/software/gi)          ){ } else { print "ERROR Correct Keywords: software\n";         $bolean = 0;};
	if ( ( @$data[9]  =~/kick_numb_output/gi)  ){ } else { print "ERROR Correct Keywords: kick_numb_output\n"; $bolean = 0;};
	if ( ( @$data[10] =~/init_relax/gi)        ){ } else { print "ERROR Correct Keywords: init_relax\n";       $bolean = 0;};
	return $bolean;
}
###################################
# Read files
sub read_file {
	# filename
	my ($filename) = @_;
	(my $input_file = $filename) =~ s/\s//g;
	my @array          = ();
	# open file
	open(FILE, "<", $input_file ) || die "Can't open $input_file: $!";
	while (my $row = <FILE>) {
		chomp($row);
		push (@array,$row);
	}
	close (FILE);
	# return array	
	return @array;
}
###################################
# Join string
sub string_tmp {
	my ($array_input) = @_;
	#
	my $concat_string;
	for ( my $i=2 ; $i < scalar (@{$array_input}); $i++) {
		$concat_string.="@$array_input[$i] ";
	}
	return $concat_string;
}
###################################
# Function to determine if a string is numeric
sub looks_like_number {
	my ($array_input) = @_;	
	#
	my $number;
	my $element;
	my @array_elements = ();
	for ( my $i=2 ; $i < scalar (@{$array_input}); $i++) {
		$number  = 0;
		if ( @$array_input[$i] =~ /^[0-9,.E]+$/ ) {
			$number = @$array_input[$i];
		} else {
			$element = @$array_input[$i];
		}
		for ( my $j = 0 ; $j < $number ; $j++) {
			push (@array_elements,$element);
		}
	}
	return @array_elements;
}
###################################
# Min selection: Returns one vectors containing the minimum x, y and z coordinates
sub min_vector {
	my ($coord_x,$coord_y,$coord_z) = @_;
	my @array = ();
	# variables
	my $minx  = 0; 
	my $miny  = 0;
	my $minz  = 0;
	# sorted coords array
	my @sorted_coord_x = sort { $a <=> $b } @$coord_x ;
	my @sorted_coord_y = sort { $a <=> $b } @$coord_y ;
	my @sorted_coord_z = sort { $a <=> $b } @$coord_z ;
	# assign min coord
	$minx  = $sorted_coord_x[0] ;
	$miny  = $sorted_coord_y[0] ;
	$minz  = $sorted_coord_z[0] ;
	@array = ($minx, $miny, $minz);
	# return array	
	return @array;
}
###################################
# Max selection: Returns one vectors containing the minimum x, y and z coordinates
sub max_vector {
	my ($coord_x,$coord_y,$coord_z) = @_;
	my @array = ();
	# variables
	my $maxx  = 0; 
	my $maxy  = 0;
	my $maxz  = 0;
	# sorted coords array
	my @sorted_coord_x = sort { $b <=> $a } @$coord_x ;
	my @sorted_coord_y = sort { $b <=> $a } @$coord_y ;
	my @sorted_coord_z = sort { $b <=> $a } @$coord_z ;
	# assign min coord
	$maxx  = $sorted_coord_x[0] ;
	$maxy  = $sorted_coord_y[0] ;
	$maxz  = $sorted_coord_z[0] ;
	@array = ($maxx, $maxy, $maxz);
	# return array		
	return @array;
}
###################################
# Logo
sub logo {
	print "\n";
	print "       _____                         __  .__        ____  __.__        __     \n";
	print "      /     \\   ____   _____   _____/  |_|__| ____ |    |/ _|__| ____ |  | __ \n";
	print "     /  \\ /  \\_/ __ \\ /     \\_/ __ \\   __\\  |/ ___\\|      < |  |/ ___\\|  |/ / \n";
	print "    /    Y    \\  ___/|  Y Y  \\  ___/|  | |  \\  \\___|    |  \\|  \\  \\___|    <  \n";
	print "    \\____|__  /\\___  >__|_|  /\\___  >__| |__|\\___  >____|__ \\__|\\___  >__|_ \\ \n";
	print "            \\/     \\/      \\/     \\/             \\/        \\/       \\/     \\/ \n";
	print "\n                               TiznadoLab\n";
	print "\n";
	my $datestring = localtime();
	print "                        $datestring\n\n";
}
###################################
# Euclidean distance between points
sub Euclidean_distance {
	# array coords basin 1 and basin 2
	my ($p1,$p2,$p3, $axis_x, $axis_y, $axis_z) = @_;
	# variables
	my $x1 = $axis_x;
	my $y1 = $axis_y;
	my $z1 = $axis_z;
	# measure distance between two point
	my $dist = sqrt(
					($x1-$p1)**2 +
					($y1-$p2)**2 +
					($z1-$p3)**2
					); 
	return $dist;
}
###################################
# Between points
sub Mult_coords {
	# array coords basin 1 and basin 2
	my ($p1,$p2,$p3, $axis_x, $axis_y, $axis_z) = @_;
	# variables
	my $x1 = $axis_x;
	my $y1 = $axis_y;
	my $z1 = $axis_z;
	# measure distance between two point
	my $dist = 	$x1*$p1 +
				$y1*$p2 +
				$z1*$p3 ; 
	return $dist;
}
###################################
# Average
sub promedio {
	my ($num,$data) = @_;
	# write file
	my $sum = 0;
	for ( my $i = 0 ; $i < $num ; $i = $i + 1 ){
		$sum+= @$data[$i];
	}
	my $div = $sum / $num;
	return $div; 
}
###################################
# Grigoryan Springborg similitud
sub Grigoryan_Springborg {
	my ($numb_atoms,$array_coord_x_1,$array_coord_y_1, $array_coord_z_1,
	                $array_coord_x_2,$array_coord_y_2, $array_coord_z_2) = @_;
	#
	my @distance_alpha = ();
	my @distance_beta  = ();
	#
	my $sum_1 = 0;
	for ( my $i = 0 ; $i < $numb_atoms ; $i = $i + 1 ){
		for ( my $j = 0 ; $j < $numb_atoms ; $j = $j + 1 ){
			if ( $i < $j ){
				my $distance = Euclidean_distance (@$array_coord_x_1[$i],@$array_coord_y_1[$i],@$array_coord_z_1[$i],
												@$array_coord_x_1[$j],@$array_coord_y_1[$j],@$array_coord_z_1[$j]);
				push (@distance_alpha,$distance);
			}
		}
	}
	#
	my $sum_2 = 0;
	for ( my $i = 0 ; $i < $numb_atoms ; $i = $i + 1 ){
		for ( my $j = 0 ; $j < $numb_atoms ; $j = $j + 1 ){
			if ( $i < $j ){
				my $distance = Euclidean_distance (@$array_coord_x_2[$i],@$array_coord_y_2[$i],@$array_coord_z_2[$i],
												@$array_coord_x_2[$j],@$array_coord_y_2[$j],@$array_coord_z_2[$j]);
				push (@distance_beta,$distance);
			}
		}
	}
	#
	my $InterDist_1 = (2/($numb_atoms*($numb_atoms-1)));
	my $InterDist_2 = (($numb_atoms*($numb_atoms-1))/2);  
	#
	my @mol_alpha = ();
	my @mol_beta  = ();
	my @idx_1 = sort { $distance_alpha[$a] <=> $distance_alpha[$b] } 0 .. $#distance_alpha;
	my @idx_2 = sort { $distance_beta[$a]  <=> $distance_beta[$b]  } 0 .. $#distance_beta;
	@mol_alpha = @distance_alpha[@idx_1];
	@mol_beta  = @distance_beta[@idx_2];
	#
	my $num_1 = scalar (@mol_alpha);
	my $num_2 = scalar (@mol_beta);
	my $dim_alpha =  promedio ($num_1,\@mol_alpha);
	my $dim_beta  =  promedio ($num_2,\@mol_beta);
	#
	my $sumX;
	my $sumY;
	# Sin normalizar
	for ( my $i = 0 ; $i < $InterDist_2 ; $i = $i + 1 ){
		my $mult = ( $mol_alpha[$i] - $mol_beta[$i] )**2;
		$sumX+=$mult;
	}
	my $Springborg_1 = sqrt( $InterDist_1 * $sumX );
	# Normalizado
	for ( my $i = 0 ; $i < $InterDist_2 ; $i = $i + 1 ){
		my $mult = ( ($mol_alpha[$i]/$dim_alpha) - ($mol_beta[$i]/$dim_beta) )**2;
		$sumY+=$mult;
	}
	my $Springborg_2 = sqrt( $InterDist_1 * $sumY );
	#
	return $Springborg_2; 
}
###################################
# Delete repeat data
sub uniq {
	my %seen;
	grep !$seen{$_}++, @_;
}
###################################
# Index duplicate data
sub index_elements {
	my ($duplicate_name,$files_name) = @_;
	# reference arrays	
	my @array_1     = @{$duplicate_name}; 
	my @array_2     = @{$files_name};
	my @array_index = ();
	#
	my @filtered = uniq(@array_1);
	foreach my $u (@filtered){
		my @del_indexes = reverse( grep { $array_2[$_] eq "$u" } 0..$#array_2);
		foreach my $k (@del_indexes) {
			push (@array_index,$k);
		}
	}
	return @array_index;
}
###################################
# Verify similar structure
sub info_duplicate_structures {
	my ($number_cycle,$numb_atoms,$coords_xyz,$ncpus) = @_;
	my @array_coords = @{$coords_xyz};
	#	
	#my $threshold_duplicate = 0.005;
	#
	my $sum                 =  ($number_cycle + ($number_cycle/2));
	my $add                 =  int ($sum);
	#
	my %Info_Coords = ();
	my @array_keys  = ();
	for (my $i=0; $i < $add ; $i++) { 
		my $id            = sprintf("%06d",$i);
		my @abc           = split (/\n/,$array_coords[$i]);
		$Info_Coords{$id} = \@abc;
		push(@array_keys,$id);
	}
	my $pm        = new Parallel::ForkManager($ncpus);
	my $iteration = 0;
	#
	my $file_tmp = "Dupli.tmp";
	open (FILE, ">$file_tmp") or die "Unable to open XYZ file: $file_tmp";
	my $file_log = "Duplicates_info.log";
	open (LOGDUPLI, ">$file_log") or die "Unable to open XYZ file: $file_log"; 
	print LOGDUPLI "\n# # # SUMMARY SIMILAR STRUCTURES # # #\n\n";
	for ( my $x = 0 ; $x < scalar (@array_keys); $x = $x + 1 ) {
		$pm->start($iteration) and next;
		# All children process havee their own random.			
		srand();
		for ( my $y = 0 ; $y < scalar (@array_keys); $y = $y + 1 ) {
			if ( $x < $y ){
				#
				my @matrix_1 = @{$Info_Coords{$array_keys[$x]}};
				my @matrix_2 = @{$Info_Coords{$array_keys[$y]}};
				# # # # # # # # # # # # # # # # #
				#
				my @array_name_atoms_1 = ();
				my @array_coord_x_1    = ();
				my @array_coord_y_1    = ();
				my @array_coord_z_1    = ();
				#
				my @array_name_atoms_2 = ();
				my @array_coord_x_2    = ();
				my @array_coord_y_2    = ();
				my @array_coord_z_2    = ();	
				#
				for ( my $i = 0 ; $i < $numb_atoms ; $i = $i + 1 ){
					my @array_tabs_1  = split (/\s+/,$matrix_1[$i]);
					#
					my $radii_val;
					my $other_element = 0;
					if ( exists $Atomic_number{$array_tabs_1[0]} ) {
						# exists
						$radii_val = $Atomic_number{$array_tabs_1[0]};
						$array_name_atoms_1[++$#array_name_atoms_1] = $radii_val;
					} else {
						# not exists
						$radii_val = $array_tabs_1[0] ;
						$array_name_atoms_1[++$#array_name_atoms_1] = $radii_val;
					}
					$array_coord_x_1[++$#array_coord_x_1]   = $array_tabs_1[1];
					$array_coord_y_1[++$#array_coord_y_1]   = $array_tabs_1[2];
					$array_coord_z_1[++$#array_coord_z_1]   = $array_tabs_1[3];
				}
				#
				for ( my $i = 0 ; $i < $numb_atoms ; $i = $i + 1 ){
					my @array_tabs_2 = split (/\s+/,$matrix_2[$i]);
					#
					my $radii_val;
					my $other_element = 0;
					if ( exists $Atomic_number{$array_tabs_2[0]} ) {
						# exists
						$radii_val = $Atomic_number{$array_tabs_2[0]};
						$array_name_atoms_2[++$#array_name_atoms_2] = $radii_val;
					} else {
						# not exists
						$radii_val = $array_tabs_2[0] ;
						$array_name_atoms_2[++$#array_name_atoms_2] = $radii_val;
					}
					$array_coord_x_2[++$#array_coord_x_2]   = $array_tabs_2[1];
					$array_coord_y_2[++$#array_coord_y_2]   = $array_tabs_2[2];
					$array_coord_z_2[++$#array_coord_z_2]   = $array_tabs_2[3];
				}
				my $Springborg = Grigoryan_Springborg ($numb_atoms,\@array_coord_x_1 ,\@array_coord_y_1 ,\@array_coord_z_1 
																,\@array_coord_x_2 ,\@array_coord_y_2 ,\@array_coord_z_2 );												  
				#
				if ( $Springborg < $threshold_duplicate ) {
					my $number      = sprintf '%.6f', $Springborg;
					print FILE "$array_keys[$y]\n";
					print FILE "Value = $number\n";
					print LOGDUPLI "# Isomer$array_keys[$x] ~= Isomer$array_keys[$y]\n";
					print LOGDUPLI "# Value = $number\n";
					print LOGDUPLI "------------------------\n";
				}
				#
			}
			$iteration++;
		}
		$pm->finish;	
	}
	close (FILE);
	# Paralel
	$pm->wait_all_children;
	# # #
	my @data_tmp = read_file ($file_tmp);	
	my @duplicates_name = ();
	my @Value_simi      = ();
	foreach my $info (@data_tmp) {
		if ( ($info =~ m/Value/) ) {
			my @array_tabs = ();
			@array_tabs    = split ('\s+',$info);
			push (@Value_simi,$array_tabs[2]);
		} else {
			push (@duplicates_name,$info);
		}
	}
	# Delete similar structures
	my @index_files = index_elements (\@duplicates_name,\@array_keys);
	my $file_xyz = "Duplicates_coords.xyz";
	open (DUPLIXYZ, ">$file_xyz") or die "Unable to open XYZ file: $file_log"; 
	my $count_sim_struc = 0;
	foreach my $id_index (@index_files) {
		my @coords_dup = @{$Info_Coords{$array_keys[$id_index]}};
		print DUPLIXYZ scalar (@coords_dup);
		print DUPLIXYZ "\n";
		print DUPLIXYZ "Isomer$array_keys[$id_index] Duplicate\n";
		foreach (@coords_dup) {
			print DUPLIXYZ "$_\n";
		}
		$count_sim_struc++;
	}
	print LOGDUPLI "\nNumber of Similar Structures = $count_sim_struc\n";
	close (LOGDUPLI);
	close (DUPLIXYZ);
	#
	# Delete similar structures	
	for my $k (@index_files) {
		delete $Info_Coords{$array_keys[$k]};
	}
	#
	unlink ($file_tmp);
	#
	return \%Info_Coords;
}
###################################
# Geometry relax Molecular Mechanics
sub relax_molecular_mechanics {
	# Array are send by reference
	my ($frag_1,$frag_2,$num_atoms_xyz,$relax_FF,$criteria,$steps,$conv_algorithm) = @_;
	# Reference arrays	
	my @arrayInputs  = @{$frag_1}; 
	my @arrayOutputs = @{$frag_2};
	#
	my @arrayOptMM  = ();
	my @EnergyOptMM = ();
	#
	for ( my $i=0; $i < scalar(@arrayInputs) ; $i++) {
		my ($coords_all,$energy) = OptMMBabel ($arrayInputs[$i],$arrayOutputs[$i],$relax_FF,$criteria,$steps,$conv_algorithm);
		push (@arrayOptMM,$coords_all);
		push (@EnergyOptMM,$energy);
	}
	#
	my @idx = sort { $EnergyOptMM[$a] <=> $EnergyOptMM[$b] } 0 .. $#EnergyOptMM;
	my @mol_energy = @EnergyOptMM[@idx];
	my @mol_coords = @arrayOptMM[@idx];
	#
	my $all_coords_xyz = "XYZ_OPT_MM.xyz";
	open (FILE, ">$all_coords_xyz") or die "Unable to open XYZ file: $all_coords_xyz"; 
	for ( my $i=0; $i < scalar(@arrayInputs) ; $i++) {
		print FILE "$num_atoms_xyz\n";
		print FILE "E = $mol_energy[$i] kcal/mol\n";
		print FILE "$mol_coords[$i]";
	}
	close (FILE); 
	#
	return @mol_coords;
}
###################################
# Geometry relax semiempirical
sub relax_semiempirical {
	my ($frag_1,$frag_2,$num_atoms_xyz,$relax_FF,$Charge,$Multiplicity,$ncpus,$mem,$path_bin_mopac) = @_;
	# Reference arrays	
	my @arrayInputs  = @{$frag_1}; 
	my @arrayOutputs = @{$frag_2};
	#
	for ( my $i=0; $i < scalar(@arrayInputs) ; $i++) {
		my @data_tmp = read_file ($arrayInputs[$i]);
		@data_tmp = @data_tmp[ 2 .. $#data_tmp ];
		(my $without_extension = $arrayOutputs[$i]) =~ s/\.[^.]+$//;
		my $concat;
		foreach (@data_tmp) {
			$concat.= "$_\n";
		}
		my $MopacInput = MopacInput ($without_extension,$concat,$i,$relax_FF,$Charge,$Multiplicity,$ncpus,$mem);		
		system ("$path_bin_mopac $MopacInput >tmp_mopac_1.txt 2>tmp_mopac_2.txt ");
	}
	my  @all_coords = energy_mopac ($num_atoms_xyz,"OPT_XYZ_Mopac.xyz");
	#
	unlink ("tmp_mopac_1.txt");
	unlink ("tmp_mopac_2.txt");	
	#
	for ( my $i=0; $i < scalar(@arrayOutputs); $i++) {
		#
		(my $without_extension = $arrayOutputs[$i]) =~ s/\.[^.]+$//;
		#
		unlink ("$without_extension.mop");
		unlink ("$without_extension.arc");
		unlink ("$without_extension.out");
		unlink ("$without_extension.aux");
	}
	#
	return @all_coords;
}
###################################
# Energy ouputs mopac
sub energy_mopac {
	my ($num_atoms_xyz, $name_file) = @_;	
	# directorio
	my $dir = './';
	#
	my @array = ();
	my @array_coords_mopac = ();
	# abrir directorio
	opendir(DIR, $dir) or die $!;
	#
	while (my $file = readdir(DIR)) {
		# Use a regular expression to ignore files beginning with a period
		next if ($file =~ m/^\./);
		next unless ($file =~ m/\.arc$/);
		# sin extension
		my $fileSnExt = $file;
		$fileSnExt =~ s/\..*$//;
		#
		if ( -e "$fileSnExt.arc" ) {
			push( @array, "$fileSnExt.arc");
		} else {
			print "WARNING: Mopac file $file error termination\n";		
		}
		#
	}
	closedir(DIR);
	#
	my $tam_esc = scalar (@array);
	if ($tam_esc == 0) { print "ERROR problem MOPAC $tam_esc files .arc, check .out\n"; exit(0);}
	#
	my @HeaderLines = ();
	my @ZeroPoint   = ();
	my @energyy     = ();
	my $energy      = '';
	my $number_atoms = $num_atoms_xyz;
	foreach my $i (@array) {
		#
		open(HEADER,"$i") or die "Unable to open $i";
		@HeaderLines  = <HEADER>;
		close HEADER;
		#
		while (my $HLine = shift (@HeaderLines)) {
			chomp ($HLine);
			#
			my $hatfield_1 = "TOTAL ENERGY";
			if ( $HLine =~/$hatfield_1/ ){
				$energy = $HLine;
				my @words_1 = split (" ",$energy);
				push (@energyy,$words_1[3]); 
			}
		}
	}
	#
	my @idx = sort { $energyy[$a] <=> $energyy[$b] } 0 .. $#energyy;
	my @energyy_1     = @energyy[@idx];
	my @array_1       = @array[@idx];
	#
	my $mopac_all_geome = $name_file; 
	open (ARCFILE, ">$mopac_all_geome");
	#
	for ( my $i = 0; $i < scalar(@array_1); $i++) {
		# Convert kcal/mol
		my $kcal          = 23.0605419453;
		my $theBest_E     = abs($energyy_1[0] - $energyy_1[$i]);
		# Total Energy
		my $convert_E     = ($theBest_E * $kcal);	
		#
		open (HEADER,"$array_1[$i]") or die "Unable to open $i";
		my @HeaderLines = <HEADER>;
		close HEADER;
		#
		my $count_lines = 0;
		my $first_line  = 0;
		my @array_lines = ();
		while (my $HLine = shift (@HeaderLines)) {
			my $hatfield = "FINAL GEOMETRY OBTAINED";
			if ( $HLine =~/$hatfield/ ){
				$first_line = $count_lines;			
			}
			$count_lines++;
			push (@array_lines,$HLine);
		}
		my $tmp_rest = $first_line + 3;	
		my $lala     =  $count_lines;
		#
		my $concat;
		#
		print ARCFILE "$number_atoms\n";
		print ARCFILE "$array_1[$i] ";
		print ARCFILE "$energyy_1[$i] eV ";
		my $number = sprintf '%05f', $convert_E;
		print ARCFILE "$number Kcal/mol\n";
		for ( my $i = $tmp_rest; $i < $count_lines; $i++) {
			my $wordlength = length ($array_lines[$i]);    
			#
			if ( $wordlength > 3) {
				chomp ($array_lines[$i]);
				my @words = split (" ",$array_lines[$i]);
				print ARCFILE "$words[0]\t$words[1]\t$words[3]\t$words[5]\n";
				$concat.= "$words[0]\t$words[1]\t$words[3]\t$words[5]\n";
			}
		}
		push (@array_coords_mopac,$concat);
	}
	close ARCFILE;
	return @array_coords_mopac;
}
###################################
# Check inside the box
sub check_inside_box {
	# array are send by reference
	my ($frag,$side_x,$side_y,$side_z) = @_;
	# get size
	my $resultado   = 0;
	my $nprocess    = 40;
	# 
	foreach my $key (sort(keys %$frag)) {
		my @coords = @{%$frag{$key}};
		# 
		for (my $i=0; $i < scalar(@coords);$i++){
			my ($atom,$axis_x,$axis_y,$axis_z) = split '\s+', $coords[$i];
			my $option_x = box_space ($side_x,$axis_x);
			my $option_y = box_space ($side_y,$axis_y);
			my $option_z = box_space ($side_z,$axis_z);
			#
			my $final_trial = $option_x + $option_z + $option_y;
			#
			if( $final_trial ==	 1 ) {
				$resultado = 1;
				last;
			}
		}
	}
	# verify for steric impediment, 1 yes, 0 no;
	return $resultado;		
}
###################################
# Box space search 
sub box_space {
	# array are send by reference
	my ($side,$coord) = @_;
	my $limit_pos = ( +1 * ( abs ($side) + 1));
	my $limit_neg = ( -1 * ( abs ($side) + 1));
	#
	my $option;
	if ( ( $coord < $limit_pos ) && ( $coord > $limit_neg ) ) {
		$option = 0;
	} else {
		$option = 1;
	}
	return $option;
}
####################################
# Final coords Lammps
sub coords_lammps {
	# Array are send by reference
	my ($frag_1,$num_atoms_xyz,$tmp_box,$init_relax) = @_;
	# Reference arrays	
	my @arrayInputs  = @{$frag_1};
	#
	my @total_coords = ();
	foreach my $file_xyz (@arrayInputs) {
		my @tmp = read_file ($file_xyz);
		my $string_coords;
		for (my $i = 2; $i < scalar (@tmp); $i++) {
			$string_coords.="$tmp[$i]\n";
		}
		push (@total_coords,$string_coords);
	}
	#
	my @LammpsInput_array = ();
	for (my $iteration = 0; $iteration < scalar (@arrayInputs); $iteration++) {
		(my $without_extension = $arrayInputs[$iteration]) =~ s/\.[^.]+$//;
		my $LammpsInput = LammpsInput ($without_extension,$total_coords[$iteration],$iteration,$init_relax,$tmp_box);
		push (@LammpsInput_array,$LammpsInput);
	}
	#
	my @Outputs_lammps = submit_queue_lammps (\@LammpsInput_array,$path_bin_lammps);
	my ($value_coords_sort,$value_energy_sort) = coords_energy_lammps ($num_atoms_xyz,\@Outputs_lammps);
	my @value_energy  = @{$value_energy_sort};
	my @value_coords  = @{$value_coords_sort};		
	for ( my $i=0; $i < scalar(@Outputs_lammps); $i++) {
		(my $without_ext = $Outputs_lammps[$i]) =~ s/\.[^.]+$//;
		unlink ("$without_ext.dat");
		unlink ("$without_ext.out");	
		unlink ("$without_ext.xyz");
		unlink ("$without_ext.in");
	}
	#
	my @idx        = sort { $value_energy[$a] <=> $value_energy[$b] } 0 .. $#value_energy;
	my @mol_energy = @value_energy[@idx];
	my @mol_coords = @value_coords[@idx];
	#
	my $all_coords_xyz = "XYZ_OPT_ReaxFF.xyz";
	open (FILE, ">$all_coords_xyz") or die "Unable to open XYZ file: $all_coords_xyz"; 
	for ( my $i=0; $i < scalar(@Outputs_lammps) ; $i++) {
		my $resta = abs($mol_energy[0]) - abs($mol_energy[$i]);	
		print FILE "$num_atoms_xyz\n";
		my $Kcalmol = sprintf("%.4f", $resta);
		print FILE "$i Isomer $Kcalmol kcal/mol\n";
		print FILE "$mol_coords[$i]";
	}
	close (FILE);	
	#
	return @mol_coords;
}
####################################
# Input file Lammps
sub LammpsInput {
	#
	my $filebase         = $_[0];
	my $coordsMM         = $_[1];
	my $LammpsInput      = "$filebase.in";
	my $LammpsCoords     = "$filebase.dat";
	my $LammpsOutputAxis = "$filebase.xyz";
	my $iteration        = $_[2];
	my $Headerfile       = $_[3];
	my $Box_Length       = $_[4];
	#
	my @words = split (/\n/,$coordsMM);
	my %num_atoms_lammps = ();
	#
	open (COORDSFILE, ">$LammpsCoords");
	print COORDSFILE "# $LammpsCoords file format coords\n";
	print COORDSFILE "\n";
	my $count    = 0;
	my @elements = ();
	foreach my $i (@words){
		my @axis    = split (" ",$i);
		my $label  = $axis[0];  
		push (@elements,$label);
		$count++;
	}
	print COORDSFILE "$count atoms\n";
	my @unique_elements   = uniq @elements;
	my $num_uniq_elements = scalar (@unique_elements);
	print COORDSFILE "$num_uniq_elements atom types\n";
	print COORDSFILE "\n";
	my ($mi_x,$mi_y,$mi_z,$ma_x,$ma_y,$ma_z) = split (" ",$Box_Length);
	print COORDSFILE " $mi_x   $ma_x     xlo xhi\n";
	print COORDSFILE " $mi_y   $ma_y     ylo yhi\n";
	print COORDSFILE " $mi_z   $ma_z     zlo zhi\n";
	print COORDSFILE "\n";
	print COORDSFILE " Masses\n";
	print COORDSFILE "\n";
	my $numb_at = 1;
	for (my $i = 0 ; $i < $num_uniq_elements; $i++) {
		my $mass_val  = 0;
		my $element   = $unique_elements[$i];
		if ( exists $Atomic_mass{$element} ) {
			$mass_val = $Atomic_mass{$element};
		} else {
			$mass_val = $other_element ;
		}
		$num_atoms_lammps{$element} = $numb_at;
		print COORDSFILE " $numb_at $mass_val\n";
		$numb_at++;		
	}
	print COORDSFILE "\n";
	print COORDSFILE " Atoms\n";
	print COORDSFILE "\n";	
	my $count_atoms = 1;
	my $tmp   = "0.0";
	foreach my $i (@words){
		my @axis    = split (" ",$i);
		#
		my $label  = $axis[0];  
		my $axis_x = $axis[1];
		my $axis_y = $axis[2];
		my $axis_z = $axis[3];
		#
		print COORDSFILE "   $count_atoms  $num_atoms_lammps{$label}  $tmp  $axis_x  $axis_y  $axis_z\n";
		$count_atoms++;
	}
	print COORDSFILE "\n";
	close (COORDSFILE);
	#
	open (LAMMPSFILE, ">$LammpsInput");
	print LAMMPSFILE "# REAX FF parameters\n";
	print LAMMPSFILE "#\n";
	print LAMMPSFILE "dimension       3\n";
	print LAMMPSFILE "boundary        p p p\n";
	print LAMMPSFILE "units		    real\n";
	print LAMMPSFILE "\n";
	print LAMMPSFILE "atom_style      charge\n";
	print LAMMPSFILE "atom_modify     map array sort 0 0.0\n";
	print LAMMPSFILE "\n";
	print LAMMPSFILE "read_data	    $LammpsCoords\n";
	print LAMMPSFILE "\n";
	print LAMMPSFILE "pair_style	    reax/c NULL\n";
	#
	print LAMMPSFILE "pair_coeff	    * * $Headerfile";
	for (my $i = 0 ; $i < $num_uniq_elements; $i++) {
		my $mass_val  = 0;
		my $element   = $unique_elements[$i];
		print LAMMPSFILE "$element ";
	}		
	print LAMMPSFILE "\n";	
	#
	print LAMMPSFILE "neighbor	    2 bin\n";
	print LAMMPSFILE "neigh_modify	every 10 check yes\n";
	print LAMMPSFILE "fix             2 all qeq/reax 1 0.0 10.0 1e-6 reax/c\n";
	print LAMMPSFILE "\n";
	print LAMMPSFILE "# should equilibrate much longer in practice\n";
	print LAMMPSFILE "#\n";
	print LAMMPSFILE "fix             1 all nvt temp 300 300 10\n";
	print LAMMPSFILE "#fix		        1 all npt temp 273.0 273.0 10.0 iso 1.0 1. 2000.0\n";
	print LAMMPSFILE "timestep        0.2\n";
	print LAMMPSFILE "thermo_style    custom step temp epair pe ke etotal \n";
	print LAMMPSFILE "thermo          1\n";
	print LAMMPSFILE "#\n";
	print LAMMPSFILE "dump             1 all custom 100 $LammpsOutputAxis element x y z\n";
	#
	print LAMMPSFILE "dump_modify      1 element ";
	for (my $i = 0 ; $i < $num_uniq_elements; $i++) {
		my $mass_val  = 0;
		my $element   = $unique_elements[$i];
		print LAMMPSFILE "$element ";
	}		
	print LAMMPSFILE "\n";		
	#
	print LAMMPSFILE "\n";
	print LAMMPSFILE "# $steps_lammps step of minimize\n";	
	print LAMMPSFILE "minimize           $criteria_lammps $criteria_lammps $steps_lammps $steps_lammps\n";
	print LAMMPSFILE "\n";
	#
	return $filebase;
}
####################################
# Submit jobs lammps
sub submit_queue_lammps {
	my ($arrayInputs,$path_lammps) = @_;
	my @Inputs_lammps  = @{$arrayInputs};
	my @Outputs_lammps = ();
	for ( my $i=0 ; $i < scalar(@Inputs_lammps); $i++) {
		my $env = `$path_lammps -in $Inputs_lammps[$i].in >$Inputs_lammps[$i].out`;
		push (@Outputs_lammps,"$Inputs_lammps[$i].out");
	}
	return @Outputs_lammps
}
####################################
# Extract Lammps energy results
sub coords_energy_lammps {
	my ($num_atoms_xyz,$arrayInputs) = @_;	
	#
	my @array              = ();
	my @array_coords_mopac = ();
	my @energy_lmp         = ();
	my @coords_lmp         = ();
	foreach my $files ( @{$arrayInputs} ) {
		(my $without_extension = $files) =~ s/\.[^.]+$//;
		open(HEADER,"$without_extension.out") or die "Unable to open $files";
		my @HeaderLines  = <HEADER>;
		close HEADER;
		#
		my $count_lines = 0; 
		for ( my $i=0; $i < scalar(@HeaderLines); $i++) {		
			if ( ($HeaderLines[$i]=~/Energy/gi ) && ($HeaderLines[$i]=~/initial/gi ) 
			  && ($HeaderLines[$i]=~/next-to-last/gi ) && ($HeaderLines[$i]=~/final/gi ) ){
				$count_lines = $i;
			}		
		}
		my $data_E = $count_lines + 1;
		my ($E_initial,$E_next_to_last,$E_final) = split (" ",$HeaderLines[$data_E]);
		push (@energy_lmp,$E_final);
	}
	#
	foreach my $files ( @{$arrayInputs} ) {
		(my $without_extension = $files) =~ s/\.[^.]+$//;
		open(HEADER,"$without_extension.xyz") or die "Unable to open $files";
		my @HeaderLines  = <HEADER>;
		close HEADER;
		#
		my $string_coords;
		my $count_lines = 0; 
		for ( my $i=0; $i < scalar(@HeaderLines); $i++) {		
			if ( ($HeaderLines[$i]=~/ITEM/gi ) && ($HeaderLines[$i]=~/ATOMS/gi ) 
			  && ($HeaderLines[$i]=~/element/gi ) && ($HeaderLines[$i]=~/x/gi ) ){
				$count_lines = $i;
			}		
		}
		my $data_xyz = $count_lines + $num_atoms_xyz;		
		for ( my $i = ($count_lines + 1); $i <= $data_xyz; $i++) {
			chomp ($HeaderLines[$i]);
			#print "$HeaderLines[$i]\n";
			$string_coords.="$HeaderLines[$i]\n";
		}
		push (@coords_lmp,$string_coords);
	}
	return (\@coords_lmp,\@energy_lmp);
}
####################################
# Format coords XYZ
sub coords_XYZG {
	# Array are send by reference
	my ($frag_1,$num_atoms_xyz) = @_;
	# Reference arrays	
	my @arrayInputs  = @{$frag_1};
	#
	my @total_coords = ();
	foreach my $file_xyz (@arrayInputs) {
		my @tmp = read_file ($file_xyz);
		my $string_coords;
		for (my $i = 2; $i < scalar (@tmp); $i++) {
			$string_coords.="$tmp[$i]\n";
		}
		push (@total_coords,$string_coords);
	}
	#
	my $all_coords_xyz = "XYZ_Coords.xyz";
	open (FILE, ">$all_coords_xyz") or die "Unable to open XYZ file: $all_coords_xyz"; 
	for ( my $i=0; $i < scalar(@total_coords) ; $i++) {
		print FILE "$num_atoms_xyz\n";
		print FILE "$i Isomer\n";
		print FILE "$total_coords[$i]";
	}
	close (FILE);	
	#
	return @total_coords;
}



################################
# if less than two arguments supplied, display usage
my ($file_name) = @ARGV;
#
my $tiempo_inicial = new Benchmark; #funcion para el tiempo de ejecucion del programa
#
if (not defined $file_name) {
	logo ();
	die "\nStochastic Fragment Kick Search must be run with:\n\nUsage:\n\t perl kick.pl [configure-file]\n";
	exit;  
}
logo ();
#
my @delete_rot;
my @arrayInputs  = ();
my @arrayOutputs = ();
my @arrayOptMM   = ();
my @EnergyOptMM  = ();
# read and parse files
my @data          = read_file($file_name);
my @arrays_errors = ();
# data parse
my $Num_of_geometries_input  = 0;
my $Num_of_geometries_output = 0;
#
my $Box;
my @Box_dimensions = ();
my ($Box_x,$Box_y,$Box_z );
my $option_box;
#
my $atoms;
my @Atoms        = ();
my $Num_of_atoms = 0;

my $fragments    = 0;
my @Fragments    = ();
my $Num_of_fragments; 
#
my $Submit_guff;
my @Submit_parameters = ();
my $ncpus;
my $mem;
#
my $charge_multi;
my @charge_multi_parameters = ();
my $Charge; 
my $Multiplicity;
#
my $header;
my $fragm_fix;
#
my $software;
#
my $init_relax;
my $soft_relax;
#
foreach my $a_1 (@data){
	if ( ($a_1=~/#/gi ) ){
	#	print "$a_1\n";
	} else {
		if ( ($a_1=~/kick_numb_input/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);		
			# Identify empty string
			if (!defined($tmp[2])) {			
				print "ERROR input population numbers empty\n";
				exit;
			} else {
				$Num_of_geometries_input = $tmp[2];
			}	
			#
			$arrays_errors[0] = "kick_numb_input";
		}		
		if ( ($a_1=~/box_size/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string			
			if (!defined($tmp[2])) {
				print "MESSAGE Automatic size box\n";
				$option_box = 0;
			} else {
				my $var_tmp = string_tmp (\@tmp);
				$Box = $var_tmp;
				@Box_dimensions = split(/,/, $Box);
				$Box_x = $Box_dimensions[0];
				$Box_y = $Box_dimensions[1];
				$Box_z = $Box_dimensions[2];
				$option_box = 1;
			}
			#
			$arrays_errors[1] = "box_size";			
		}
		if ( ($a_1=~/chemical_formula/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				print "WARNING chemical formula empty\n";
				$Num_of_atoms = 0;
			} else {
				@Atoms = looks_like_number (\@tmp);
				$Num_of_atoms = scalar (@Atoms);
			}
			#
			$arrays_errors[2] = "chemical_formula";			
		}
		if ( ($a_1=~/fragments/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string	
			if (!defined($tmp[2])) {
				print "WARNING fragments empty\n";
				$Num_of_fragments = 0;
			} else {
				my $var_tmp       = string_tmp (\@tmp);			
				$fragments        = $var_tmp;
				@Fragments        = split(/,/, $fragments);
				$Num_of_fragments = scalar (@Fragments);
			}
			#
			$arrays_errors[3] = "fragments";			
		}
		if ( ($a_1=~/core_mem/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				# default cpus 1 and memory 1GB
				$ncpus             = 1;
				$mem               = 1;
			} else {
				my $var_tmp       = string_tmp (\@tmp);
				$Submit_guff       = $var_tmp;
				@Submit_parameters = split(/,/, $Submit_guff);
				$ncpus             = $Submit_parameters[0];
				$mem               = $Submit_parameters[1];
			}
			#
			$arrays_errors[4] = "core_mem";			
		}
		if ( ($a_1=~/charge_multi/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				# default multiplicity 1 and charge 0
				$Charge       = 0; 
				$Multiplicity = 1;
			} else {
				my $var_tmp   = string_tmp (\@tmp);
				$charge_multi = $var_tmp;
				@charge_multi_parameters = split(/,/, $charge_multi);
				$Charge       = $charge_multi_parameters[0]; 
				$Multiplicity = $charge_multi_parameters[1];
			}
			#
			$arrays_errors[5] = "charge_multi";			
		}
		if ( ($a_1=~/header/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				print "ERROR theory level empty\n";
				exit;
			} else {
				my $var_tmp = string_tmp (\@tmp);			
				$header     = $var_tmp;
			}
			#
			$arrays_errors[6] = "header";			
		}
		if ( ($a_1=~/fragm_fix/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				print "ERROR fix molecule empty\n";
				exit;
			} else {			
				$fragm_fix = $tmp[2];
			}
			#
			$arrays_errors[7] = "fragm_fix";			
		}
		if ( ($a_1=~/software/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				print "ERROR software empty\n";
				exit;
			} else {			
				$software = $tmp[2];
			}
			#
			$arrays_errors[8] = "software";			
		}
		if ( ($a_1=~/kick_numb_output/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);		
			# Identify empty string
			if (!defined($tmp[2])) {			
				print "ERROR output population numbers empty\n";
				exit;
			} else {
				$Num_of_geometries_output = $tmp[2];
			}	
			#
			$arrays_errors[9] = "kick_numb_output";
		}
		if ( ($a_1=~/init_relax/gi ) ){
			my @tmp = ();
			@tmp    = split (/\s+/,$a_1);
			# Identify empty string
			if (!defined($tmp[2])) {
				$soft_relax = 3;
			} else {
				my $var_tmp        = string_tmp (\@tmp);
				my $number_element = scalar (@tmp);
				$init_relax        = $var_tmp;
				# GAFF,Ghemical,MMFF94,MMFF94s,UFF
				if ( ($init_relax=~/GAFF/gi ) ) {
					$soft_relax = 0;
				} elsif ( ($init_relax=~/Ghemical/gi ) ) {
					$soft_relax = 0;
				} elsif ( ($init_relax=~/MMFF94/gi ) ) {
					$soft_relax = 0;	
				} elsif ( ($init_relax=~/MMFF94s/gi ) ) {
					$soft_relax = 0;
				} elsif ( ($init_relax=~/UFF/gi ) ) {
					$soft_relax = 0;
				} else {
					if ( $number_element == 3 ) {
						$soft_relax = 2;
					} else {
						$soft_relax = 1;
					}
				}
				#
			}
			#
			$arrays_errors[10] = "init_relax";			
		}
	}
}
#
if (!defined($arrays_errors[0]))  { $arrays_errors[0]  = "NO"; }
if (!defined($arrays_errors[1]))  { $arrays_errors[1]  = "NO"; }
if (!defined($arrays_errors[2]))  { $arrays_errors[2]  = "NO"; }
if (!defined($arrays_errors[3]))  { $arrays_errors[3]  = "NO"; }
if (!defined($arrays_errors[4]))  { $arrays_errors[4]  = "NO"; }
if (!defined($arrays_errors[5]))  { $arrays_errors[5]  = "NO"; }
if (!defined($arrays_errors[6]))  { $arrays_errors[6]  = "NO"; }
if (!defined($arrays_errors[7]))  { $arrays_errors[7]  = "NO"; }
if (!defined($arrays_errors[8]))  { $arrays_errors[8]  = "NO"; }
if (!defined($arrays_errors[9]))  { $arrays_errors[9]  = "NO"; }
if (!defined($arrays_errors[10])) { $arrays_errors[10] = "NO"; }
my $bolean = errors_config (\@arrays_errors);
if ( $bolean == 0) { exit; }
# Inputs for Gaussian and Mopac
if (($software=~/gaussian/gi )) {
	print "MESSAGE Choose software Gaussian\n";
} elsif (($software=~/mopac/gi )) {
	print "MESSAGE Choose software Mopac \n";
} else {
	print "ERROR Choose software Gaussian or Mopac\n";
	exit (1); 
}
#
my @total_atoms = ();
my @new_coord_x = ();
my @new_coord_y = ();
my @new_coord_z = ();
#
my $side = 0;
if ( $Num_of_fragments > 0 ) {
	foreach my $i (@Fragments) {
		(my $word_nospaces = $i) =~ s/\s//g;
		my $filename  = "$word_nospaces.cart";
		my @tmp_array = read_file("$filename");
		foreach my $j (@tmp_array) {
			my @array_tabs  = split (/\s+/,$j);
			my $element = $array_tabs[0];
			push (@new_coord_x,$array_tabs[1]);
			push (@new_coord_y,$array_tabs[2]);
			push (@new_coord_z,$array_tabs[3]);
			#
			push (@total_atoms,$element);
		}
		#
		my @array_min = min_vector (\@new_coord_x,\@new_coord_y,\@new_coord_z);
		my @array_max = max_vector (\@new_coord_x,\@new_coord_y,\@new_coord_z);
		my ($xmin,$ymin,$zmin) = @array_min;
		my ($xmax,$ymax,$zmax) = @array_max;
		#
		$side+= Euclidean_distance ($xmin,$ymin,$zmin,$xmax,$ymax,$zmax);		
	}
}
if ( $Num_of_atoms > 0 ) {
	foreach my $i (@Atoms) {
		push (@total_atoms,$i);
	}
} 
if (($Num_of_atoms == 0) && ($Num_of_fragments == 0)) {
	print "ERROR please consider atoms and/or fragments";
	exit(1);
} 
# automatic box
my @min_coords = ();
my @max_coords = ();
my ($side_plus_x,$side_plus_y,$side_plus_z);
my $side_box = 0;
if ($option_box == 0) {
	# measure side cube
	if ((($Num_of_atoms > 0) && ($Num_of_fragments > 0)) or ($Num_of_fragments > 0)) {
		#
	#	$side_box   = sprintf '%.3f',($side + 0);	
	#	my $sides = automatic_box_size (\@Atoms);		
		#
		my $sid   = automatic_box_size (\@total_atoms);	
		$side_box = sprintf '%.3f',($side + $sid);
		#
	} elsif ( $Num_of_atoms > 0 ) {
		my $sides   = automatic_box_size (\@Atoms);
		$side_box   = $sides - ($sides/$Num_of_atoms);
	}
	#
	$side_plus_x  = ($side_box / 2);
	$side_plus_y  = ($side_box / 2);
	$side_plus_z  = ($side_box / 2);		
	#
	my $side_minus = (-1 * $side_plus_x);
	@min_coords    = ($side_minus,$side_minus,$side_minus);
	@max_coords    = ($side_plus_x,$side_plus_y,$side_plus_z);
} else {
	$side_plus_x  = ($Box_x / 2);
	my $side_minus_x = (-1 * $side_plus_x);
	$side_plus_y  = ($Box_y / 2);
	my $side_minus_y = (-1 * $side_plus_y);
	$side_plus_z  = ($Box_z / 2);
	my $side_minus_z = (-1 * $side_plus_z);
	#
	@min_coords    = ($side_minus_x,$side_minus_y,$side_minus_z);
	@max_coords    = ($side_plus_x,$side_plus_y,$side_plus_z);
}
#
my $mi_x = sprintf '%.4f',$min_coords[0];
my $mi_y = sprintf '%.4f',$min_coords[1];
my $mi_z = sprintf '%.4f',$min_coords[2];
#
my $ma_x = sprintf '%.4f',$max_coords[0];
my $ma_y = sprintf '%.4f',$max_coords[1];
my $ma_z = sprintf '%.4f',$max_coords[2];
#
print "MESSAGE Box size Min = $mi_x $mi_y $mi_z\n"; 
print "MESSAGE Box size Max = $ma_x $ma_y $ma_z\n";
box_molecule (\@min_coords,\@max_coords);
#
foreach my $fil (@Fragments) {
	(my $word_nospaces = $fil) =~ s/\s//g;
	my $filename  = "$word_nospaces.cart";
	my @coordx = ();
	my @coordy = ();
	my @coordz = ();
	my @elements_new = ();
	my @array_file_fix = read_file("$filename");
	foreach my $i (@array_file_fix){
		my @Cartesian = split '\s+', $i;
		push (@coordx,$Cartesian[1]);
		push (@coordy,$Cartesian[2]);
		push (@coordz,$Cartesian[3]);
		#		
		my $element = $Cartesian[0];
		my $radii_val;
		if ( exists $Atomic_number{$element} ) {
			# exists
			$radii_val = $Atomic_number{$element};
		} else {
			# not exists
			$radii_val = $element;
		}
		push (@elements_new,$radii_val);
	} 
	# call subrutine
	my @array_center_mass = measure_center(\@coordx,\@coordy,\@coordz);
	my @array_vecinvert   = vecinvert(\@array_center_mass);
	# for coords xyz molecules, moveby {x y z} (translate selected atoms)
	my @array_catersian   = vecadd (\@coordx,\@coordy,\@coordz,\@array_vecinvert);
	#
	open (my $fh, '>', "$filename") or die "Could not open file '$filename' $!";
	for ( my $i = 0 ; $i < scalar (@coordx) ; $i = $i + 1 ){
		print $fh "$elements_new[$i]\t$array_catersian[0][$i]\t$array_catersian[1][$i]\t$array_catersian[2][$i]\n";
	}
	close $fh;
}
# Fix always first molecule
my $fix_option = 0;
if ($Num_of_fragments > 0) {
	if (($fragm_fix=~/YES/gi )) {
		print "MESSAGE Molecule constrain\n";
		$fix_option = 1;
	} else { 
		$fix_option = 0;
	}
}

#########
# Iterations
#
my $iteration = 0;
while ( $iteration < $Num_of_geometries_input ) {
	#
	@delete_rot      = ();
	my %hash_tmp     = ();
	my @multi_arrays = ();
	# filename base
	my $number      = sprintf '%04d', $iteration;
	my $filebase    = "Kick$number";
	my $XYZInput    = "$filebase.xyz";
	my $XYZOutput   = "$filebase-opt.xyz";
	# Obtener el numero total de atomos para un formato XYZ
	my $NumAtoms = scalar (@total_atoms);
	#
	for (my $i = $fix_option; $i < scalar (@Fragments); $i++) {
		(my $frag_id = $Fragments[$i]) =~ s/\s//g;
		open(FRAG,"$frag_id.cart") or die "Unable to open fragment file: $frag_id.cart";
		my @FragLines = <FRAG>;
		close FRAG;
		#
		open(ROT_FRAG,">$frag_id-$i.rot");
		# get a set of angles
		my @base_angles = gen_ptp();
		my $phi         = $base_angles[0];
		my $theta       = $base_angles[1];
		my $psi         = $base_angles[2];
		# do the trig
		my $cos_phi     = sprintf '%.6f', cos($phi);
		my $cos_theta   = sprintf '%.6f', cos($theta);
		my $cos_psi     = sprintf '%.6f', cos($psi);
		my $sin_phi     = sprintf '%.6f', sin($phi);
		my $sin_theta   = sprintf '%.6f', sin($theta);
		my $sin_psi     = sprintf '%.6f', sin($psi);
		# make the rotation matrix
		my $D = new Math::Matrix ([$cos_phi,$sin_phi,0],[-$sin_phi,$cos_phi,0],[0,0,1]);
		my $C = new Math::Matrix ([1,0,0],[0,$cos_theta,$sin_theta],[0,-$sin_theta,$cos_theta]);
		my $B = new Math::Matrix ([$cos_psi,$sin_psi,0],[-$sin_psi,$cos_psi,0],[0,0,1]);
		my $A = $B->multiply($C)->multiply($D);
		#
		while (my $Fline = shift (@FragLines)) {
			my @Cartesians              = split '\s+', $Fline;
			my ($Atom_label, @orig_xyz) = @Cartesians;
			print ROT_FRAG "$Atom_label\t";
			my $matrix_xyz  = new Math::Matrix ([$orig_xyz[0],$orig_xyz[1],$orig_xyz[2]]);
			my $trans_xyz   = ($matrix_xyz->transpose);
			my $rotated_xyz = $A->multiply($trans_xyz);
			my @new_xyz = split '\n+',$rotated_xyz;
			print ROT_FRAG "$new_xyz[0]\t$new_xyz[1]\t$new_xyz[2]\n";
		}
		close ROT_FRAG;		
	}
	#
	my $count_h;	
	if ( $fix_option == 1 ) {
		my @read_tmp = read_file ("$Fragments[0].cart");
		$hash_tmp{0} = \@read_tmp;
		$count_h = 1;
	} else { 
		$count_h = 0;
	}
	# Now translate the rotated coords
	for (my $i = $fix_option; $i < scalar (@Fragments); $i++) {
		(my $frag_id = $Fragments[$i]) =~ s/\s//g;
		#
		open(FRAG,"$frag_id-$i.rot") or die "Unable to open fragment file: $frag_id-$i.rot";
		my @FragLines = <FRAG>;
		close (FRAG);
		#
		push (@delete_rot,"$frag_id-$i.rot");
		my @base_xyz  = gen_xyz($side_plus_x,$side_plus_y,$side_plus_z);
		my $base_x    = $base_xyz[0];
		my $base_y    = $base_xyz[1];
		my $base_z    = $base_xyz[2];
		#
		my @all_elem = ();
		my @center_x = (); 
		my @center_y = ();
		my @center_z = ();		
		#
		my @lots = ();
		#
		while (my $Fline = shift (@FragLines)) {
			my @Cartesians = split '\s+', $Fline;
			my $new_x = $base_x + $Cartesians[1];			
			my $new_y = $base_y + $Cartesians[2];
			my $new_z = $base_z + $Cartesians[3];
			push (@all_elem,$Cartesians[0]);
			push (@center_x,$new_x);
			push (@center_y,$new_y);
			push (@center_z,$new_z);
			push (@lots,"$Cartesians[0]\t$new_x\t$new_y\t$new_z");
		}
		$hash_tmp{$i} = \@lots;
		$count_h++;
	}
	#
	my $tam_arr_atoms     = scalar (@Atoms);
	my $tam_arr_fragments = scalar (@Fragments);
	my $total_mol         = ($tam_arr_fragments + $tam_arr_atoms);
	#
	if ( $tam_arr_atoms > 0 ){
		foreach my $species (@Atoms) {
			my @xyz = gen_xyz($side_plus_x,$side_plus_y,$side_plus_z);
			my @tmp = ();
			push (@tmp,"$species\t$xyz[0]\t$xyz[1]\t$xyz[2]");
			$hash_tmp{$count_h} = \@tmp;
			$count_h++;
		}
	}
	#
	my $count_array = 0;
	my %new_hash_1  = ();
	my %new_hash_2  = ();	
	#
	for (my $i = 0; $i < $total_mol; $i++) {
		my @to_coords     = ();
		for (my $j = 0; $j < $total_mol; $j++) {
			if ( $i < $j ){
				$new_hash_1{$count_array} = \@{$hash_tmp{$i}};
				$new_hash_2{$count_array} = \@{$hash_tmp{$j}};
				$count_array++;
			}
		}
		#	
	}
	#
	my $add          = 0;
	my $option_check = 0;
	#
	$option_check = check_inside_box ( \%hash_tmp,$mi_x,$mi_y,$mi_z);
	$add          = steric_impediment (\%new_hash_1,\%new_hash_2);
	#
	if ( ( $add == 0 ) && ( $option_check == 0 ) )   {	
		my @new_elem_cart  = ();
		my @new_xyzc_cart  = ();		
		for (my $i = 0; $i < $total_mol; $i++) {
			my @value_array = @{$hash_tmp{$i}};
			# Aqui viene la mutacion del kick
			# esta mutacion va ser una opcion
			foreach my $dn (@value_array) {
				my @info_cart = split '\s+', $dn;
				push (@new_elem_cart, $info_cart[0]);
				push (@new_xyzc_cart, "$info_cart[1]\t$info_cart[2]\t$info_cart[3]");
			}	
		}
		#
		open (INXYZ, ">$XYZInput") or die "Unable to open XYZ file: $XYZInput"; 
		$num_atoms_xyz = $NumAtoms;
		print INXYZ "$NumAtoms\n";
		print INXYZ "\n"; 
		#
		for (my $i = 0; $i < scalar (@new_elem_cart); $i++) {
			print INXYZ "$new_elem_cart[$i]\t$new_xyzc_cart[$i]\n";
		}
		#
		close (INXYZ);
		push (@arrayInputs ,$XYZInput);
		push (@arrayOutputs,$XYZOutput);
		$iteration++;
	}

}

# Geometry relax Molecular Mechanics
my @mol_coords = ();
if ( $soft_relax == 0 ) {
	@mol_coords = relax_molecular_mechanics (\@arrayInputs,\@arrayOutputs,$num_atoms_xyz,$init_relax,
	                                         $criteria,$steps,$conv_algorithm);
} elsif ( $soft_relax == 1 ) {
	@mol_coords = relax_semiempirical (\@arrayInputs,\@arrayOutputs,$num_atoms_xyz,$init_relax,$Charge,
	                                   $Multiplicity,$ncpus,$mem,$path_bin_mopac);
} elsif ( $soft_relax == 2 ) {
	my $tmp_box = "$mi_x $mi_y $mi_z $ma_x $ma_y $ma_z";
	@mol_coords = coords_lammps (\@arrayInputs,$num_atoms_xyz,$tmp_box,$init_relax);
} else {
	@mol_coords = coords_XYZG (\@arrayInputs,$num_atoms_xyz);
}

# En esta parte va lo de lo de duplicados
print "MESSAGE Find Structures Similar\n";
my %structure_info = %{info_duplicate_structures ($Num_of_geometries_output,$num_atoms_xyz,\@mol_coords,$nprocess)};
my @keys_array     = keys %structure_info;
#
my @final_coords   = (); 
#
foreach my $my_key (sort(keys %structure_info)) {
	my @array_coords_hash = @{$structure_info{$my_key}};
	my $str = join ("\n", @array_coords_hash);
	push (@final_coords,$str);
}
#
my $length_array    = scalar @final_coords;
my $new_num_geo_out = 0;
if ($length_array < $Num_of_geometries_output ){
	$new_num_geo_out = $length_array;
} else {
	$new_num_geo_out = $Num_of_geometries_output
} 
#
my $option_soft = 0;
for ( my $i=0; $i < $new_num_geo_out; $i++) {
	(my $without_extension = $arrayOutputs[$i]) =~ s/\.[^.]+$//;
	chomp ($final_coords[$i]);
	#
	if (($software=~/gaussian/gi )) {
		G03Input ($without_extension,$header,$ncpus,$mem,$Charge,$Multiplicity,$final_coords[$i],$i);		
	}
	if (($software=~/mopac/gi )) {
		$option_soft = 3;
		my $MopacInput = MopacInput ($without_extension,$final_coords[$i],$i,$header,$Charge,$Multiplicity,$ncpus,$mem);
		system ("$path_bin_mopac $MopacInput >tmp_mopac_1.txt 2>tmp_mopac_2.txt");
	}
}
#
my $tiempo_final = new Benchmark;
my $tiempo_total = timediff($tiempo_final, $tiempo_inicial);
print "MESSAGE Execution time: ",timestr($tiempo_total),"\n";
#####
# save files
my $dir_kick= './Info_Kick';
if (-e $dir_kick and -d $dir_kick) {
	#
	if( -e "XYZ_OPT_MM.xyz" ){
		move("XYZ_OPT_MM.xyz","$dir_kick");
	}
	if( -e "OPT_XYZ_Mopac.xyz" ){
		move("OPT_XYZ_Mopac.xyz","$dir_kick");
	}
	if( -e "XYZ_OPT_ReaxFF.xyz" ){
		move("XYZ_OPT_ReaxFF.xyz","$dir_kick");
	}
	if( -e "XYZ_Coords.xyz" ){
		move("XYZ_Coords.xyz","$dir_kick");
	}
	#
	move("Duplicates_coords.xyz","$dir_kick");
	move("Duplicates_info.log","$dir_kick");
	move("BOX_kick.vmd","$dir_kick");
} else {
	#
	mkdir $dir_kick;		
	#
	if( -e "XYZ_OPT_MM.xyz" ){
		move("XYZ_OPT_MM.xyz","$dir_kick");
	}
	if( -e "OPT_XYZ_Mopac.xyz" ){
		move("OPT_XYZ_Mopac.xyz","$dir_kick");
	}
	if( -e "XYZ_OPT_ReaxFF.xyz" ){
		move("XYZ_OPT_ReaxFF.xyz","$dir_kick");
	}	
	#
	move("Duplicates_coords.xyz","$dir_kick");
	move("Duplicates_info.log","$dir_kick");
	move("BOX_kick.vmd","$dir_kick");
}

#####
# delete files 
print "MESSAGE Delete files .xyz, .rot & .dat\n";
#
for ( my $i=0; $i < scalar(@arrayOutputs); $i++) {
	#
	unlink ("$arrayOutputs[$i]");
	unlink ("$arrayInputs[$i]");
}
#
foreach (@delete_rot){
	unlink ("$_");
}
#
unlink ("tmp.dat");
unlink ("tmp_mopac_1.txt");
unlink ("tmp_mopac_2.txt");
unlink ("log.cite");
unlink ("log.lammps");
#############
# for mopac
if (( $option_soft == 3 )) {
	#
	for ( my $i=0; $i < scalar(@arrayOutputs); $i++) {
		(my $without_extension = $arrayOutputs[$i]) =~ s/\.[^.]+$//;
		unlink ("$without_extension.mop");
		unlink ("$without_extension.aux");
	}
	#
	my  @sort_coords_mopac = energy_mopac ($num_atoms_xyz,"kick_result_mopac.xyz");
	my $dir_files = './files_mopac';
	if ( -e $dir_files and -d $dir_files) {
		for ( my $i=0; $i < scalar(@arrayOutputs); $i++) {
			(my $without_extension = $arrayOutputs[$i]) =~ s/\.[^.]+$//;
			move("$without_extension.out","$dir_files");
			move("$without_extension.arc","$dir_files");
		}	
		move("kick_result_mopac.xyz","$dir_files");
	} else {
		mkdir $dir_files;
		for ( my $i=0; $i < scalar(@arrayOutputs); $i++) {
			(my $without_extension = $arrayOutputs[$i]) =~ s/\.[^.]+$//;
			move("$without_extension.out","$dir_files");
			move("$without_extension.arc","$dir_files");
		}
		move("kick_result_mopac.xyz","$dir_files");
	}
}
exit(0);