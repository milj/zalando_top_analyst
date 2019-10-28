# Usage:
# gnuplot -e "filename='../ruby/joint_pdf.dat'" plot.gp

set terminal pngcairo size 1550,1148
set output './plots/joint_pdf_with_confidence_interval_contours.png'

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
plot "./plots/berlin_map.png" binary filetype=png using 1:2:3:(127) with rgbalpha

set contours

# using contour levels printed out by search.rb
set cntrparam levels discrete 1.90482571383408e-11,1.6006151169159772e-11,9.94409234826899e-12,4.119782746306164e-12,1.178268917718287e-12

set linetype 2 lc rgb "#31b604" # green
set linetype 3 lc rgb "#ffee00" # yellow
set linetype 4 lc rgb "#feb602" # orange
set linetype 5 lc rgb "#fe0000" # light red
set linetype 6 lc rgb "#b00000" # dark red

# set x&y range to degrees again
set xrange [13.274099:13.553989]
set yrange [52.464011:52.590117]

# do not draw the surface, i.e. draw only the contours and let the background map be visible
set nosurface

splot filename using 2:1:3 with lines linewidth 5

# plot the custom legend
set key box opaque
set key width 3
set key height 3
plot NaN with points pt 5 ps 2 lc rgb "#31b604" title "95%", \
     NaN with points pt 5 ps 2 lc rgb "#ffee00" title "80%", \
     NaN with points pt 5 ps 2 lc rgb "#feb602" title "50%", \
     NaN with points pt 5 ps 2 lc rgb "#fe0000" title "20%", \
     NaN with points pt 5 ps 2 lc rgb "#b00000" title "5%"

unset multiplot
