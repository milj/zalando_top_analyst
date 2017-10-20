# Usage:
# gnuplot -e "filename='path/to/data/file.dat'" plot.gp

set terminal pngcairo size 1550,1148
set output 'brandenburg_gate_pdf.png'

# to combine PDF plot with the map of Berlin
set multiplot

# fullscreen plot
set lmargin screen 0.0
set rmargin screen 1.0
set tmargin screen 1.0
set bmargin screen 0.0

# remove the default legend
unset key

# remove tics
unset tics

# draw 3D data as flat color map
set pm3d map

set palette grey

# substracting 0.0001 degree (approximately 0.4 of the pixel size) to prevent white edge ("no data here") rounding issues
set xrange [13.274099:(13.553989-0.0001)]
set yrange [52.464011:(52.590117-0.0001)]

# plot the PDF data
splot filename using 2:1:3

# the background picture's size is 1550x1148
set xrange [0:1549]
set yrange [0:1147]

# plot the Berlin map overlay with alpha channel
plot "./plots/berlin_map.png" binary filetype=png using 1:2:3:(15) with rgbalpha

unset multiplot
