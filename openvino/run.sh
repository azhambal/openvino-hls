#!/bin/bash

set -e

# input parameters
FILE=${1:-http://stream.trafjam.ru/cam3_site/tracks-v1/mono.m3u8}

DETECTION_INTERVAL=${2:-10}

DEVICE=${3:-CPU}

TRACKING_TYPE=${4:-short-term}

if [[ $DEVICE == "GPU" ]]; then
  DECODER="decodebin ! video/x-raw\(memory:VASurface\),format=NV12"
elif [[ $DEVICE == "CPU" ]]; then
  DECODER="decodebin ! video/x-raw"
else
  echo Error: wrong value for DEVICE parameter
  echo Possible values: CPU, GPU
  exit
fi

SINK_ELEMENT="gvawatermark ! x264enc bitrate=1024 ! \
              video/x-h264,profile=\"high\" ! mpegtsmux ! \
			  hlssink location=segment_%05d.ts target-duration=5 max-files=10"

MODEL_1=person-vehicle-bike-detection-crossroad-0078

RECLASSIFY_INTERVAL=10

if [[ $FILE == "/dev/video"* ]]; then
  SOURCE_ELEMENT="v4l2src device=${FILE}"
elif [[ $FILE == *"://"* ]]; then
  SOURCE_ELEMENT="urisourcebin buffer-size=4096 uri=${FILE}"
else
  SOURCE_ELEMENT="filesrc location=${FILE}"
fi

PROC_PATH() {
    echo $(dirname "$0")/model_proc/$1.json
}

DETECTION_MODEL=person-vehicle-bike-detection-crossroad-0078.xml 

DETECTION_MODEL_PROC=$(PROC_PATH $MODEL_1)

PIPELINE="gst-launch-1.0 \
  ${SOURCE_ELEMENT} ! $DECODER ! queue ! \
  gvadetect model=$DETECTION_MODEL \
            model-proc=$DETECTION_MODEL_PROC \
            inference-interval=${DETECTION_INTERVAL} \
            threshold=0.6 \
            device=${DEVICE} ! \
  queue ! \
  gvatrack tracking-type=${TRACKING_TYPE} ! \
  queue ! \
  $SINK_ELEMENT"

echo ${PIPELINE}
eval ${PIPELINE}
