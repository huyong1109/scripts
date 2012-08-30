#! /bin/csh -f

echo '-----------------------------------------------------------------'
echo '     Set env variables available to model setup scripts (below): '
echo '-----------------------------------------------------------------'

setenv LICOMROOT /home/hxm/WORK/licom2.0		# LICOM dir
setenv SRCPATH   $LICOMROOT/src
setenv BLDPATH   $LICOMROOT/bld
setenv DATAPATH  $LICOMROOT/DATA
setenv EXEROOT   $LICOMROOT/test     # EXE dir
setenv EXESRC    $EXEROOT/src
setenv EXEDIR    $EXEROOT/exe
setenv RUNTYPE   initial                    # run type initial or continue
#setenv RUNTYPE  continue                    # run type initial or continue
set HISTOUT = 1                           # model output every 5 years
set RESTOUT = 12                           # model restar file outpur every 12 months
set NTASKS  = 12 
set NTHRDS  = 1 

set LID = "`date +%y%m%d-%H%M%S`"    

echo '-----------------------------------------------------------------'
echo '     Copy the source codes                                       ' 
echo '-----------------------------------------------------------------'

#rm *.out
#mkdir -p  $EXEROOT
#cd        $EXEROOT
#mkdir -p  $EXESRC
#mkdir -p  $EXEDIR
#cp    -pf $SRCPATH/*.F90 $EXESRC/.
#cp    -pf $SRCPATH/*.c $EXESRC/.
#cp    -pf $BLDPATH/Makefile $EXESRC/Makefile

cd $EXESRC
#
echo '-----------------------------------------------------------------'
echo '     Produce the pre-compile file def-undef h                    '
echo '-----------------------------------------------------------------'

#\cat >! def-undef.h << EOF
#define NX_PROC 12
#define NY_PROC 132
#define SPMD
#define  SYNCH
#undef  FRC_ANN
#define CDFIN
#undef  FRC_DAILY
#define SOLAR
#define  ACOS
#define  BIHAR
#undef  SMAG_FZ
#undef  SMAG_OUT
#define NETCDF
#define BOUNDARY
#define NODIAG
#undef  ICE
#undef SHOW_TIME
#undef DEBUG
#undef COUP
#undef  ISO
#define D_PRECISION
#define  CANUTO
#undef SOLARCHLORO
#undef LDD97
#define TSPAS
#undef  SMAG
#define JMT_GLOBAL 1683
#EOF

echo '-----------------------------------------------------------------'
echo '     Compile and Link                                            '
echo '-----------------------------------------------------------------'

#make -f Makefile clean
#make -f Makefile > makelog.$LID

#if ( $status != 0 ) then
#echo "compile failure!"
#exit 1
#endif

echo '-----------------------------------------------------------------'
echo '     Produce the namelist file                                   '
echo '-----------------------------------------------------------------'

if      ($RUNTYPE == 'initial' ) then
  set NSTART = 1
else if ($RUNTYPE == 'continue') then
  set NSTART = 0
endif
#
cd $EXEDIR
#
#\cat >! ocn.parm << EOF
#&namctl
#  DLAM       =0.1            !grid distance
#  AM_TRO     = 60
#  AM_EXT     = 60
#  IDTB       =6
#  IDTC       =180
#  IDTS       =180 
#  AFB1       =0.43
#  AFC1       =0.43
#  AFT1       =0.43
#  AMV        = 1.0E-3
#  AHV        = 0.3E-4
#  NUMBER     = 1
#  NSTART     = 0
#  diag_msf   =.true.
#  diag_mth   =.true.
#  diag_bsf   =.true. 
#  IO_HIST    = 1
#  IO_REST    = 1
#  klv        = 30
#  rest_freq  = 1
#  out_dir    = $EXEDIR
#&end
#EOF
#

echo '-----------------------------------------------------------------'
echo '     Link the data files to excutive directory                   '
echo '-----------------------------------------------------------------'
#ln -sf $DATAPATH/BASIN.nc                                 $EXEDIR/BASIN.nc
#ln -sf $DATAPATH/dncoef.h                                 $EXEDIR/dncoef.h 
#ln -sf $DATAPATH/fort.22.0044-03-01                       $EXEDIR/fort.22.0044-03-01
#ln -sf $DATAPATH/fort.22.0044-03-02                       $EXEDIR/fort.22.0044-03-02
#ln -sf $DATAPATH/INDEX.DATA                               $EXEDIR/INDEX.DATA
#ln -sf $DATAPATH/MODEL.FRC                                $EXEDIR/MODEL.FRC
#ln -sf $DATAPATH/ocn.parm                                 $EXEDIR/ocn.parm    
#ln -sf $DATAPATH/rpointer.ocn                             $EXEDIR/rpointer.ocn    
#ln -sf $DATAPATH/TSinitial                                $EXEDIR/TSinitial
#ln -sf $DATAPATH/lwdn.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/lwdn.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/q_10.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/q_10.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/rain.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/rain.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/slp.db.1948-2007.daymean.05APR2010.nc    $EXEDIR/slp.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/snow.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/snow.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/swdn.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/swdn.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/t_10.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/t_10.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/u_10.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/u_10.db.1948-2007.daymean.05APR2010.nc
#ln -sf $DATAPATH/v_10.db.1948-2007.daymean.05APR2010.nc   $EXEDIR/v_10.db.1948-2007.daymean.05APR2010.nck
#
#ln -s $EXESRC/licom2 .

echo '-----------------------------------------------------------------'
echo '     Run the model using poe or llsub                            '
echo '-----------------------------------------------------------------'
bsub -a mvapich –o output.%J –e error.%J -n 12 mpirun.lsf /examples/cpi
bsub -a intelmpi -o out.$LID -n $NTASKS mpirun.lsf ./licom2
#mpiexec -n $NTASKS ./licom2
