#!/bin/csh
setenv HOME /home/hxm/WORK/hy/kau_agcm_fv50km
set NTASK=64
set outlist=`pwd`
#if(-e list )rm list
#touch list
set outlist=`pwd`"/list"

@ sday     =1      
@ smonth   =4   
@ syear    =1997

@ eday     =1
@ emonth   =4
@ eyear    =1997
echo $sday $smonth $syear $eday $emonth $eyear

cd $HOME

echo '-----------------------------------------------------------------'
echo '   Set TAU environment'
echo '-----------------------------------------------------------------'

set LID = "`date +%y%m%d-%H%M%S`"    
setenv TAUOUT  $HOME/out/tauout.$LID
mkdir -p    $TAUOUT  
set path=(/home/hxm/tau/x86_64/bin $path)
setenv TAULIBDIR /home/hxm/tau/x86_64/lib
setenv TAU_MAKEFILE $TAULIBDIR/Makefile.tau-icpc-mpi-pdt
setenv TRACEDIR  $TAUOUT 
setenv PROFILEDIR $TAUOUT 
#setenv TAU_OPTIONS  -optKeepFiles  # -optTauSelectFile=licomselect.tau'
setenv TAU_OPTIONS '-optKeepFiles  -optTauSelectFile=select.tau'
#setenv TAU_OPTIONS ' -optCompInst' # -optTauSelectFile=licomselect.tau'
#setenv TAU_OPTIONS '-optPreProcess ' # -optCompInst' # -optTauSelectFile=licomselect.tau'
setenv TAU_TRACE 1
setenv TAU_PROFILE 1
setenv TAU_CALLPATH 1
setenv TAU_CALLPATH_DEPTH   100
#setenv TAU_TRACK_HEAP 1 
#setenv TAU_TRACK_MASSAGE 1 


echo '-----------------------------------------------------------------'
echo '   Makefile.tau'
echo '-----------------------------------------------------------------'

cd $HOME/src/ctl_F90
rm makelog*
make -f Makefile.tau clean
make -f Makefile.tau  >makelog.$LID

if ( $status != 0 ) then
echo "compile failure!"
exit 1
else
echo "compile success!"
endif

cd $HOME

@ iy=$syear

while($iy <=  $eyear )
echo $iy
@ nyr  = $iy          

@   mody=`echo $iy  |awk '{ print $1 % 4}'`
echo "mody " $mody
if( $mody == 0) set cmonday=(31 29 31  30  31  30  31  31  30  31  30  31)
if( $mody != 0) set cmonday=(31 28 31  30  31  30  31  31  30  31  30  31)

@ ims=1
if ($iy == $syear)then
@ ims =$smonth
endif


@ ime=12
if ($iy == $eyear)then
@ ime =$emonth
endif

while($ims <= $ime )

@ nmon  = $ims 
@ idys=1

if ($iy == $syear & $ims == $smonth)then
@ idys =$sday  
endif

@ idye=$cmonday[$ims]
if ($iy == $eyear & $ims == $emonth)then
@ idye =$eday  
endif

@ nday = $idys 
while($idys <= $idye )

@ nday = $nday + 1
if( $nday > $cmonday[$nmon] )then
@ nday = 1
@ nmon= $nmon + 1
endif
if( $nmon > 12    )then
@ nmon = 1
@ nyr= $nyr  + 1
endif

echo " ids ims iy         " $idys   $ims   $iy
echo " inext day nom year " $nday   $nmon  $nyr    
#############################
@ iy2=$iy - 1900
@ nyr2=$nyr - 1900
set iyear = `awk 'BEGIN{ printf("%2.2d", '$iy2') }' /dev/null`
set fyear = `awk 'BEGIN{ printf("%2.2d", '$nyr2') }' /dev/null`
set imon = `awk 'BEGIN{ printf("%2.2d", '$ims') }' /dev/null`
set fmon = `awk 'BEGIN{ printf("%2.2d", '$nmon') }' /dev/null`
set iday = `awk 'BEGIN{ printf("%2.2d", '$idys') }' /dev/null`
set fday = `awk 'BEGIN{ printf("%2.2d", '$nday') }' /dev/null`
echo $iyear $imon $iday $fyear $fmon  $fday
##########################################################
# execute the agcm for one day
# make output directory
setenv DIR   $HOME/out/exp1/$iyear$imon$iday
if (! -e $DIR) mkdir -p $DIR
cd $DIR
# move needed files
cp -f $HOME/csh/ctl/need/* .

# modify SYSIN file
sed "s/yymm2/$iyear${imon}${iday}/"      SYSIN_exp1.nml  > tmp1
sed "s/yymm3/$fyear${fmon}${fday}/"       tmp1   > tmp2
sed "s/xxx/$iyear,$imon,$iday/"         tmp2   > tmp1
sed "s/yyy/$fyear,$fmon,$fday/"         tmp1   > tmp2
sed "s/zzz/30/"                      tmp2   > SYSIN



echo execute the agcm for one day

#mpirun -machinefile /home3/ashfaq/kau_agcm_fv50km/csh/ctl/host.name4  -np  32   /home3/ashfaq/kau_agcm_fv50km/exe/v1_fv50km < SYSIN 
#bsub -o output.%J -e error.%J -n $NTASK -q "hpc_linux" "mpirun -np $NTASK  $HOME/exe/lzh<SYSIN"
bsub -a intelmpi -o output.%J -e error.%J -n $NTASK -q "hpc_linux" mpirun.lsf  $HOME/exe/tauF90 < SYSIN
#time mpirun -machinefile $HOME/exe/mpd4 -perhost 6 -np 24 $HOME/exe/hy < SYSIN
#bsub -o output.%J -n $NTASK -q "hpc_linux" $HOME/exe/hxm < SYSIN

echo AFTER MPIRUN

#########################################################
@ idys = $idys + 1
end

@ ims = $ims + 1
end

@ iy =$iy + 1
end

exit
