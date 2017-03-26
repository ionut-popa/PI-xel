A simple script using the http://pi-xel.io filtering method to improve JPEG file compression.

Usage: ./jpegfilter.sh options
Options:
     -q Output JPEG quality, default 95
     -f input file
     -m Filtering method, default 1
        1 - apply high quality adaptive focus filtering on the full RGB image
        2 - apply high quality adaptive focus filtering on Y, and low quality filters to UV
        3 - apply no filtering on Y, and low quality filters to UV

The script create a file prefixed with pf of the original name

E.g. for batch processing
for P in `ls test*.jpg`
do 
    ./jpegfilter.sh -q 95 -m 3 -f $P
done


Parameters:
-m 1 and 2 are slighty loosy but preserve image details - producing more compression
-m 3 is unnoticible lossy - producing less compression 


Results 
Original size: 2848kB
-m 1 param:    2568kB (90%)
-m 2 param:    2460kB (86%)
-m 3 param:    2700kB (95%)
