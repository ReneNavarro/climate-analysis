function usage {
    echo "USAGE: bash $0 varfile var contfile contvar date1 date2 lat outfile python_exe code_dir"
    echo "   envfile:    Input file name for colour plot"
    echo "   var:        Variable for colour plot"
    echo "   contfile:   Input file name for contour plot"
    echo "   contvar:    Variable for contour plot"
    echo "   date1:      First date to plot"
    echo "   date2:      Second date to plot"
    echo "   lat:        Latitude line to emphasise"
    echo "   outfile:    Output file name"
    echo "   python_exe:  Python executable"
    echo "   code_dir:    Directory that plot_map.py is in"
    echo "   e.g. bash $0 env_data.nc env zg_data.nc zg 1986-05-22_2006-07-29 -55 plot.png /usr/local/anaconda/bin/python ~/climate-analysis/visualisation"
    exit 1
}

nargs=10

if [ $# -ne $nargs ] ; then
  usage
fi

envfile=$1
var=$2
contfile=$3
contvar=$4
date1=$5
date2=$6
lat=$7
outfile=$8
python_exe=$9
code_dir=$10
  

#ticks="0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0" 
#extend=max
palette=hot_r
#levels="-150 -120 -90 -60 -30 0 30 60 90 120 150" 


${python_exe} ${code_dir}/plot_map.py ${envfile} ${var} ${date1} ${date1} none colour0 1 1 2 \
--infiles ${envfile} ${var} ${date2} ${date2} none colour0 2 \
--palette ${palette} \
--output_projection SouthPolarStereo \
--subplot_headings ${date1} ${date2} \
--infiles ${contfile} ${contvar} ${date1} ${date1} none contour0 1 \
--infiles ${contfile} ${contvar} ${date2} ${date2} none contour0 2 \
--ofile ${outfile} \
--lat_lines ${lat} 0.5 dashed
#--colourbar_ticks ${ticks}
#--figure_size 9 16 --extend ${extend}

