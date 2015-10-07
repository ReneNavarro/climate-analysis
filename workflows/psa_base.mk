# zw_base.mk
#
# Description: Basic workflow that underpins all other zonal wave (zw) workflows 
#
# To execute:
#	make -n -B -f zw_base.mk  (-n is a dry run) (-B is a force make)

# Pre-processing:
#	The regirdding (if required) needs to be done beforehand 
#	(probably using cdo remapcon2,r360x181 in.nc out.nc)
#	So does the zonal anomaly


# Define marcos
include psa_config.mk

all : ${TARGET}

# Core variables

V_ORIG=${DATA_DIR}/va_${DATASET}_${LEVEL}_daily_native.nc
U_ORIG=${DATA_DIR}/ua_${DATASET}_${LEVEL}_daily_native.nc

## Streamfunction

SF_ORIG=${DATA_DIR}/sf_${DATASET}_${LEVEL}_daily_native.nc
${SF_ORIG} : ${U_ORIG} ${V_ORIG}
	bash ${DATA_SCRIPT_DIR}/calc_wind_quantities.sh streamfunction $< ua $(word 2,$^) va $@ ${PYTHON} ${DATA_SCRIPT_DIR} ${TEMPDATA_DIR}

SF_ANOM_RUNMEAN=${DATA_DIR}/sf_${DATASET}_${LEVEL}_${TSCALE_LABEL}-anom-wrt-all_native.nc
${SF_ANOM_RUNMEAN} : ${SF_ORIG} 
	cdo ${TSCALE} -ydaysub $< -ydayavg $< $@

SF_ZONAL_ANOM=${DATA_DIR}/sf_${DATASET}_${LEVEL}_daily_native-zonal-anom.nc
${SF_ZONAL_ANOM} : ${SF_ORIG}		
	bash ${DATA_SCRIPT_DIR}/calc_zonal_anomaly.sh $< sf $@ ${PYTHON} ${DATA_SCRIPT_DIR} ${TEMPDATA_DIR}

SF_ZONAL_ANOM_RUNMEAN=${DATA_DIR}/sf_${DATASET}_${LEVEL}_${TSCALE_LABEL}_native-zonal-anom.nc 
${SF_ZONAL_ANOM_RUNMEAN} : ${SF_ZONAL_ANOM}
	cdo ${TSCALE} $< $@

## Rotated meridional wind

VROT_ORIG=${DATA_DIR}/vrot_${DATASET}_${LEVEL}_daily_native-${NPLABEL}.nc
${VROT_ORIG} : ${U_ORIG} ${V_ORIG}
	bash ${DATA_SCRIPT_DIR}/calc_vrot.sh ${NPLAT} ${NPLON} $< eastward_wind $(word 2,$^) northward_wind $@ ${PYTHON} ${DATA_SCRIPT_DIR} ${TEMPDATA_DIR}

VROT_ANOM_RUNMEAN=${DATA_DIR}/vrot_${DATASET}_${LEVEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.nc
${VROT_ANOM_RUNMEAN} : ${VROT_ORIG} 
	cdo ${TSCALE} -ydaysub $< -ydayavg $< $@
	ncatted -O -a bounds,time,d,, $@
	ncks -O -x -v time_bnds $@

## Composite variable

VAR_ORIG=${DATA_DIR}/${VAR_SHORT}_${DATASET}_surface_daily_native.nc
VAR_ANOM_RUNMEAN=${DATA_DIR}/${VAR_SHORT}_${DATASET}_surface_${TSCALE_LABEL}-anom-wrt-all_native.nc
${VAR_ANOM_RUNMEAN} : ${VAR_ORIG} 
	cdo ${TSCALE} -ydaysub $< -ydayavg $< $@

## Southern Annular Mode

PSL_ORIG=${DATA_DIR}/psl_${DATASET}_surface_daily_native-shextropics30.nc
PSL_RUNMEAN=${DATA_DIR}/psl_${DATASET}_surface_${TSCALE_LABEL}_native-shextropics30.nc
${PSL_RUNMEAN} : ${PSL_ORIG}
	cdo ${TSCALE} $< $@

SAM_INDEX=${INDEX_DIR}/sam_${DATASET}_surface_${TSCALE_LABEL}_native.nc 
${SAM_INDEX} : ${PSL_RUNMEAN}
	${PYTHON} ${DATA_SCRIPT_DIR}/calc_climate_index.py SAM $< psl $@

## Nino 3.4

TOS_ORIG=${DATA_DIR}/tos_${DATASET}_surface_daily_native-tropicalpacific.nc
TOS_RUNMEAN=${DATA_DIR}/tos_${DATASET}_surface_${TSCALE_LABEL}_native-tropicalpacific.nc
${TOS_RUNMEAN} : ${TOS_ORIG}
	cdo ${TSCALE} $< $@

NINO34_INDEX=${INDEX_DIR}/nino34_${DATASET}_surface_${TSCALE_LABEL}_native.nc 
${NINO34_INDEX} : ${TOS_RUNMEAN}
	${PYTHON} ${DATA_SCRIPT_DIR}/calc_climate_index.py NINO34 $< tos $@




# PSA demonstration

## EOF analysis

EOF_ANAL=${PSA_DIR}/eof-sf_${DATASET}_${LEVEL}_${TSCALE_LABEL}_native-sh-zonal-anom.nc
${EOF_ANAL} : ${SF_ZONAL_ANOM_RUNMEAN}
	${PYTHON} ${DATA_SCRIPT_DIR}/calc_eof.py --maxlat 0.0 --time 1979-01-01 2014-12-31 --eof_scaling 3 --pc_scaling 1 $< streamfunction $@


# PSA identification

## Phase and amplitude of each Fourier component

FOURIER_COEFFICIENTS=${PSA_DIR}/fourier-vrot_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.nc 
${FOURIER_COEFFICIENTS} : ${VROT_ANOM_RUNMEAN}
	${PYTHON} ${DATA_SCRIPT_DIR}/calc_fourier_transform.py $< vrot $@ 1 10 coefficients --latitude ${LAT_SEARCH_MIN} ${LAT_SEARCH_MAX} --valid_lon ${LON_SEARCH_MIN} ${LON_SEARCH_MAX} --avelat --sign_change --env_max 4 7

## Hilbert transformed signal

INVERSE_FT=${PSA_DIR}/ift-${WAVE_LABEL}-vrot_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.nc  
${INVERSE_FT} : ${VROT_ANOM_RUNMEAN}
	${PYTHON} ${DATA_SCRIPT_DIR}/calc_fourier_transform.py $< vrot $@ ${WAVE_MIN} ${WAVE_MAX} hilbert --latitude ${LAT_SEARCH_MIN} ${LAT_SEARCH_MAX} --valid_lon ${LON_SEARCH_MIN} ${LON_SEARCH_MAX} --avelat

## PSA date lists
ALL_DATES_PSA=${PSA_DIR}/dates-psa_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.txt 
${ALL_DATES_PSA} : ${FOURIER_COEFFICIENTS}
	${PYTHON} ${DATA_SCRIPT_DIR}/psa_date_list.py $< $@ 

FILTERED_DATES_PSA=${PSA_DIR}/dates-psa_duration-gt${DURATION}_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.txt 
${FILTERED_DATES_PSA} : ${FOURIER_COEFFICIENTS}
	${PYTHON} ${DATA_SCRIPT_DIR}/psa_date_list.py $< $@ --duration_filter ${DURATION}  

## PSA stats lists
ALL_STATS_PSA=${PSA_DIR}/stats-psa_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.csv 
${ALL_STATS_PSA} : ${FOURIER_COEFFICIENTS}
	${PYTHON} ${DATA_SCRIPT_DIR}/psa_date_list.py $< $@ --full_stats



# Visualisation

## PSA phase plot (histogram)
PLOT_PSA_PHASE_HIST=${PSA_DIR}/psa-phase-histogram_wave${FREQ}-duration-gt${DURATION}-seasonal_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.png
${PLOT_PSA_PHASE_HIST} : ${ALL_STATS_PSA}
	${PYTHON} ${VIS_SCRIPT_DIR}/plot_psa_stats.py $< phase_distribution $@ --min_duration ${DURATION} --seasonal --epochs --phase_res 0.75

## PSA phase plot (composites)
PLOT_PSA_PHASE_COMP=${PSA_DIR}/psa-phase-composites_wave${FREQ}-duration-gt${DURATION}_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all-season_native-${NPLABEL}.png
${PLOT_PSA_PHASE_COMP} : ${FOURIER_COEFFICIENTS} ${SF_ANOM_RUNMEAN}
	bash ${VIS_SCRIPT_DIR}/plot_psa_phase_composites.sh $< $(word 2,$^) ${FREQ} ${DURATION} $@ ${PYTHON} ${DATA_SCRIPT_DIR} ${VIS_SCRIPT_DIR} ${TEMPDATA_DIR}

## PSA seasonality plot (histogram)

PLOT_SEASONALITY=${PSA_DIR}/psa-seasonality-phase-range_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.png 
${PLOT_SEASONALITY} : ${FOURIER_COEFFICIENTS}
	bash ${VIS_SCRIPT_DIR}/plot_psa_phase_seasonality.sh $< ${FREQ} $@ ${PYTHON} ${DATA_SCRIPT_DIR} ${VIS_SCRIPT_DIR} ${TEMPDATA_DIR}
	
## PSA duration plot (histogram)

PLOT_DURATION=${PSA_DIR}/psa-duration_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.png 
${PLOT_DURATION} : ${ALL_DATES_PSA}
	${PYTHON} ${VIS_SCRIPT_DIR}/plot_date_list.py $< $@ --plot_types duration_histogram

## Event phase/amplitude plot (line graph)
EVENT_PLOT=${PSA_DIR}/psa-event-summary_wave6-duration-gt${DURATION}_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.png
${EVENT_PLOT} : ${ALL_STATS_PSA}
	${PYTHON} ${VIS_SCRIPT_DIR}/plot_psa_stats.py $< event_summary $@ --min_duration ${DURATION}

## PSA variable composites plot (spatial)

PLOT_VARCOMPS=${PSA_DIR}/psa-${VAR_SHORT}-composite-phase-range_${DATASET}_${LEVEL}-${LAT_LABEL}-${LON_LABEL}_${TSCALE_LABEL}-anom-wrt-all_native-${NPLABEL}.png 
${PLOT_VARCOMPS} : ${FOURIER_COEFFICIENTS} ${SF_ANOM_RUNMEAN} ${VAR_ANOM_RUNMEAN}
	bash ${VIS_SCRIPT_DIR}/plot_psa_var_composites.sh $< $(word 2,$^) $(word 3,$^) ${VAR_SHORT} ${VAR_LONG} ${FREQ} $@ ${PYTHON} ${DATA_SCRIPT_DIR} ${VIS_SCRIPT_DIR} ${TEMPDATA_DIR}

## PSA check (spatial map and FT for given dates)

.PHONY : psa_check
psa_check : ${FILTERED_DATES_PSA} ${SF_ANOM_RUNMEAN} ${VROT_ANOM_RUNMEAN}
	bash ${VIS_SCRIPT_DIR}/plot_psa_check.sh $<	 $(word 2,$^) streamfunction $(word 3,$^) rotated_northward_wind vrot 1986 1988 ${MAP_DIR} ${PYTHON} ${VIS_SCRIPT_DIR}

## SAM vs ENSO

SAM_VS_NINO34_PLOT=${INDEX_DIR}/sam-vs-nino34-wave6phase_${DATASET}_surface_${TSCALE_LABEL}_native.png
${SAM_VS_NINO34_PLOT} : ${SAM_INDEX} ${NINO34_INDEX} ${FOURIER_COEFFICIENTS} ${ALL_DATES_PSA}
	${PYTHON} ${VIS_SCRIPT_DIR}/plot_scatter.py $(word 1,$^) sam $(word 2,$^) nino34 $@ --colour $(word 3,$^) wave6_phase --zero_lines --cmap Greys --ylabel nino34 --xlabel SAM --date_filter $(word 4,$^)





# PSA analysis

## Composites for each of the phase groupings

### Get dates for the specific phases

#/usr/local/anaconda/bin/python ~/climate-analysis/data_processing/psa_date_list.py /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/psa/fourier-vrot_ERAInterim_500hPa-lat10S10Nmean-lon115E230Ezeropad_030day-runmean-anom-wrt-all_native-np20N260E.nc /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/psa/dates-psa_ERAInterim_500hPa-lat10S10Nmean-lon115E230Ezeropad_030day-runmean-anom-wrt-all_native-np20N260E_wave7phase29-39.txt --phase_filter 29 39

### Calculate the composite

#/usr/local/anaconda/bin/python ~/climate-analysis/data_processing/calc_composite.py /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/sf_ERAInterim_500hPa_030day-runmean-anom-wrt-all_native.nc sf /mnt/meteo0/data/simmonds/dbirving/temp/sf-psa-w5-phase62-70_ERAInterim_500hPa-lat10S10Nmean-lon115E230Ezeropad_030day-runmean-anom-wrt-all_native-np20N260E.nc --date_file /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/psa/dates-psa-w5-phase62-70_ERAInterim_500hPa-lat10S10Nmean-lon115E230Ezeropad_030day-runmean-anom-wrt-all_native-np20N260E.txt --no_sig

### Plot the composite

#bash plot_psa_phase_composites.sh


## Plot the timescale spectrum

#/usr/local/anaconda/bin/python /home/STUDENT/dbirving/climate-analysis/visualisation/plot_timescale_spectrum.py /mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/vrot_ERAInterim_500hPa_daily-anom-wrt-all_native-np20N260E.nc vrot	/mnt/meteo0/data/simmonds/dbirving/ERAInterim/data/psa/figures/vrot-r2spectrum_ERAInterim_500hPa_daily-anom-wrt-all_native-np20N260E.png --latitude -10 10 --runmean 365 180 90 60 30 15 10 5 1 --scaling R2 --valid_lon 115 230 --window 10 --date_curve dummy_DJF_dates.txt DJF --date_curve dummy_MAM_dates.txt MAM --date_curve dummy_JJA_dates.txt JJA --date_curve dummy_SON_dates.txt SON
