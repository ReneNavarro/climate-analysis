ftype=png

# Explantory slide

#date=2001-07-16

## sf and wind
#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/sf_ERAInterim_500hPa_030day-runmean_native-zonal-anom.nc sf ${date} ${date} none contour0 1 \
#--output_projection SouthPolarStereo --subplot_headings July_2001 \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/ua_ERAInterim_500hPa_030day-runmean_native.nc ua ${date} ${date} none uwind0 1 \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/va_ERAInterim_500hPa_030day-runmean_native.nc va ${date} ${date} none vwind0 1 \
#--flow_type streamlines --streamline_colour 0.7 --contour_levels -20 -15 -10 -5 0 5 10 15 20 \
#--ofile example-sf-wind_${date}.${ftype}
#    
## just wind
#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
#--output_projection SouthPolarStereo --subplot_headings July_2001 \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/ua_ERAInterim_500hPa_030day-runmean_native.nc ua ${date} ${date} none uwind0 1 \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/va_ERAInterim_500hPa_030day-runmean_native.nc va ${date} ${date} none vwind0 1 \
#--flow_type streamlines --streamline_colour 0.4 \
#--ofile example-wind_${date}.${ftype}
#
# sf and wind
#for wavenum in 1 3
#do
#    /usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
#    --infile /mnt/meteo0/data/simmonds/dbirving/temp/wave${wavenum}-sf-zonal-anom_amos_2001-07-16.nc iftsf ${date} ${date} none contour0 1 \
#    --output_projection SouthPolarStereo --contour_levels -20 -15 -10 -5 0 5 10 15 20 \
#    --ofile example-wave${wavenum}-sf-zonal-anom_${date}.${ftype}
#done



# Wave envelope spatial plot

#date1=1986-05-22
#date2=2006-07-29
#
#for date in ${date1} ${date2}
#do
#
#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
#--palette brewer_YlOrRd_09 --output_projection SouthPolarStereo --subplot_headings ${date} \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/sf_ERAInterim_500hPa_030day-runmean_native-zonal-anom.nc sf ${date} ${date} none contour0 1 \
#--ofile env-cmap-${date}.${ftype} --line -55 -55 0 359.9 0.5 dashed PlateCarree_Dateline high \
#--contour_levels -20 -15 -10 -5 0 5 10 15 20 \
#--colourbar_ticks 0 2 4 6 8 10 12 14 16 18 \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/zw/envva_w19_ERAInterim_500hPa_030day-runmean_native.nc envva ${date} ${date} none colour0 1 \
#--no_colourbar

#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
#--output_projection SouthPolarStereo --subplot_headings ${date} \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/sf_ERAInterim_500hPa_030day-runmean_native-zonal-anom.nc sf ${date} ${date} none contour0 1 \
#--ofile env-no-cmap-${date}.${ftype} --line -55 -55 0 359.9 0.5 dashed PlateCarree_Dateline high \
#--contour_levels -20 -15 -10 -5 0 5 10 15 20
#
#done


# Hilbert line plot

#for date in ${date1} ${date2}
#do
#
#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_hilbert.py \
#/mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/va_ERAInterim_500hPa_030day-runmean_native.nc va \
#line-env_${date}.${ftype} 1 1 --latitude -55 --dates ${date} --wavenumbers 1 9
#
#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_hilbert.py \
#/mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/va_ERAInterim_500hPa_030day-runmean_native.nc va \
#line-ft_${date}.${ftype} 1 1 --latitude -55 --dates ${date} --wavenumbers 1 9 --highlights 1 3 --noenv
#
#done

# Composites
#
#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
#--output_projection SouthPolarStereo \
#--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/zw/figures/composites/sf-composite_pwigt90pct_ERAInterim_500hPa_030day-runmean-anom-wrt-all_native-shextropics15.nc sf_annual none none none contour0 1 \
#--contour_levels -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 \
#--ofile sf_temporal_composite_annual.${ftype}

/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_map.py 1 1 \
--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/zw/figures/composites/sf-composite_pwigt90pct_ERAInterim_500hPa_030day-runmean_native-zonal-anom-shextropics15.nc sf_annual none none none contour0 1 \
--output_projection SouthPolarStereo \
--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/zw/figures/composites/ua-composite_pwigt90pct_ERAInterim_500hPa_030day-runmean_native-shextropics15.nc ua_annual none none none uwind0 1 \
--infile /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/zw/figures/composites/va-composite_pwigt90pct_ERAInterim_500hPa_030day-runmean_native-shextropics15.nc va_annual none none none vwind0 1 \
--ofile sf_zonal_composite_annual.${ftype} --flow_type streamlines --contour_levels -12.5 -10 -7.5 -5 -2.5 0 2.5 5 7.5 10 12.5 --streamline_colour 0.7

