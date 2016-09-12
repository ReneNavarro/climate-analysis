"""
Filename:     plot_delsole.py
Author:       Damien Irving, irving.damien@gmail.com
Description:  Recreate plot from DelSole et al (2016)

"""

# Import general Python modules

import sys, os, pdb
import argparse
import numpy
import matplotlib.pyplot as plt
import seaborn
import iris


# Import my modules

cwd = os.getcwd()
repo_dir = '/'
for directory in cwd.split('/')[1:]:
    repo_dir = os.path.join(repo_dir, directory)
    if directory == 'climate-analysis':
        break

modules_dir = os.path.join(repo_dir, 'modules')
sys.path.append(modules_dir)

try:
    import general_io as gio
except ImportError:
    raise ImportError('Must run this script from anywhere within the climate-analysis git repo')


# Define functions

experiment_names = {('CSIRO-Mk3-6-0', 'historicalMisc', 3): 'noAA',
                    ('CSIRO-Mk3-6-0', 'historicalMisc', 4): 'AA',
                    ('IPSL-CM5A-LR', 'historicalMisc', 3): 'AA',
                    ('IPSL-CM5A-LR', 'historicalMisc', 4): 'noAA'}

experiment_colors = {'noAA': 'r',
                     'AA': 'b',
                     'historical': 'y',
                     'piControl': '0.5',
                     'Argo': 'g'}


def check_attributes(x_cube, y_cube):
    """Check that attributes match and return experiment."""

    # FIXME: Need to handle obs attributes

    x_model = x_cube.attributes['model_id']
    x_experiment = x_cube.attributes['experiment_id']
    x_physics = x_cube.attributes['physics_version']

    y_model = y_cube.attributes['model_id']
    y_experiment = y_cube.attributes['experiment_id']
    y_physics = y_cube.attributes['physics_version']

    assert x_model == y_model
    assert x_experiment == y_experiment
    assert x_physics == y_physics

    atts = (x_model, x_experiment, float(x_physics))

    if atts in experiment_names.keys():
        experiment = experiment_names[atts]
    else:
        experiment = x_experiment

    return experiment, x_model


def calc_trend(x_data, y_data, experiment):
    """Calculate linear trend.

    polyfit returns [a, b] corresponding to y = a + bx

    """

    a_coefficient, b_coefficient = numpy.polynomial.polynomial.polyfit(x_data, y_data, 1)
    x_trend = numpy.arange(x_data.min(), x_data.max(), 0.01)
    y_trend = a_coefficient + b_coefficient * x_trend
    print experiment, 'trend:', b_coefficient

    return x_trend, y_trend


def main(inargs):
    """Run the program."""
 
    data_dict = {}
    for experiment in experiment_colors.keys():
        data_dict[(experiment, 'x_data')] = numpy.array([]) 
        data_dict[(experiment, 'y_data')] = numpy.array([])

    metadata_dict = {}
    for xfile, xvar, yfile, yvar in inargs.file_pair:
        x_cube = iris.load_cube(xfile, xvar)
        y_cube = iris.load_cube(yfile, yvar)

        experiment, model = check_attributes(x_cube, y_cube)
        metadata_dict[xfile] = x_cube.attributes['history']
        metadata_dict[yfile] = y_cube.attributes['history']

        data_dict[(experiment, 'x_data')] = numpy.append(data_dict[(experiment, 'x_data')], x_cube.data)
        if yvar in ['precipitation_flux', 'water_evaporation_flux']:
            data_dict[(experiment, 'y_data')] = numpy.append(data_dict[(experiment, 'y_data')], y_cube.data * 86400)
        else:
            data_dict[(experiment, 'y_data')] = numpy.append(data_dict[(experiment, 'y_data')], y_cube.data)

    fig = plt.figure(figsize=(12,8))
    for experiment, color in experiment_colors.iteritems():
        x_data = data_dict[(experiment, 'x_data')]
        y_data = data_dict[(experiment, 'y_data')]

        if numpy.any(x_data):
            plt.scatter(x_data[::inargs.thin], y_data[::inargs.thin], facecolors='none', edgecolors=color, label=experiment)
            if experiment in ['AA', 'noAA']:
                x_trend, y_trend = calc_trend(x_data, y_data, experiment)
                plt.plot(x_trend, y_trend, color=color)

    plt.legend(loc=4)

    if yvar == 'sea_surface_salinity':
        plt.ylabel('Salinity amplification (g/kg)')
    elif yvar == 'precipitation_flux':
        plt.ylabel('Global mean precipitation (mm/day)')
    elif yvar == 'water_evaporation_flux':
        plt.ylabel('Global mean evaporation (mm/day)')
    plt.xlabel('Global mean temperature (K)')
    plt.title(model)

    # Write output
    plt.savefig(inargs.outfile, bbox_inches='tight')
    gio.write_metadata(inargs.outfile, file_info=metadata_dict)


if __name__ == '__main__':

    extra_info =""" 
author:
  Damien Irving, irving.damien@gmail.com
    
"""

    description='Recreate plot from DelSole et al (2016)'
    parser = argparse.ArgumentParser(description=description,
                                     epilog=extra_info, 
                                     argument_default=argparse.SUPPRESS,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument("outfile", type=str, help="Output file name")

    parser.add_argument("--file_pair", type=str, action='append', default=[], nargs=4,
                        metavar=('X_DATA', 'X_VAR', 'Y_DATA', 'Y_VAR'), help="x and y data pair")
    parser.add_argument("--thin", type=int, default=1,
                        help="Stride for thinning the data (e.g. 3 will keep one-third of the data) [default: 1]")

    args = parser.parse_args()            
    main(args)