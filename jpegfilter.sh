#!/bin/bash

function show_help {
    echo "Usage: $0 options"
    echo "Options:"
    echo "     -q Output JPEG quality, default 95"
    echo "     -f input file"
    echo "     -m Filtering method, default 1"
    echo "        1 - apply high quality adaptive focus filtering on the full RGB image"
    echo "        2 - apply high quality adaptive focus filtering on Y, and low quality filters to UV"
    echo "        3 - apply no filtering on Y, and low quality filters to UV"
}


IMAGE_FILE=""
OUTPUT_QUALITY=95
METHOD=1

while getopts "hq:f:m:" opt
do
    case $opt in
      q)
          OUTPUT_QUALITY=$OPTARG
          ;;
      f)
          IMAGE_FILE=$OPTARG
          ;;
      m)
          METHOD=$OPTARG
          ;;
      h)
          show_help
          exit 1
          ;;
    esac
done

echo "================================="
echo "  Processing: ${IMAGE_FILE} method: ${METHOD} jpeg out quality: ${OUTPUT_QUALITY}"
echo ""

convert ${IMAGE_FILE} /tmp/original.ppm


if [[ $METHOD -eq 1 ]] 
then
    ./pixel -i /tmp/original.ppm -o /tmp/filtered.ppm -q 3 -b 3
else
    # Split original image to YUV
    convert /tmp/original.ppm -colorspace YUV -channel rgb -separate +channel /tmp/original_yuv_%d.ppm

    if [[ $METHOD -eq 2 ]]
    then 
        #Y - filter original size
        ./pixel -i /tmp/original_yuv_0.ppm -o /tmp/filtered_yuv_0.ppm -q 3 -b 1
    fi 
    
    if [[ $METHOD -eq 3 ]]
    then 
        cp /tmp/original_yuv_0.ppm /tmp/filtered_yuv_0.ppm
    fi 
    
    #U - filter 100% size 
    ./pixel -i /tmp/original_yuv_1.ppm -o /tmp/filtered_yuv_1.ppm -q 1 -b 1

    #V - filter 100% size
    ./pixel -i /tmp/original_yuv_2.ppm -o /tmp/filtered_yuv_2.ppm -q 1 -b 1

    # Combine filtered YUV layers to filtered image
    convert /tmp/filtered_yuv_0.ppm /tmp/filtered_yuv_1.ppm /tmp/filtered_yuv_2.ppm -set colorspace YUV -combine /tmp/filtered.ppm
fi

convert -strip -interlace Plane -quality ${OUTPUT_QUALITY} /tmp/original.ppm /tmp/original.jpg
convert -strip -interlace Plane -quality ${OUTPUT_QUALITY} /tmp/filtered.ppm /tmp/filtered.jpg

ls -l /tmp/filtered.jpg /tmp/original.jpg 
echo "==>" ${IMAGE_FILE}
S1=$(du -b /tmp/original.jpg | cut -f1)
S2=$(du -b /tmp/filtered.jpg | cut -f1)
expr "$(( 100 * $S2 / $S1 ))"
cp /tmp/filtered.jpg $(dirname ${IMAGE_FILE})/pf_$(basename ${IMAGE_FILE}) 
