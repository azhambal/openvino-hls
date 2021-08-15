FROM openvino/ubuntu20_data_runtime:2021.4

USER root

RUN apt-get install gstreamer1.0-plugins-ugly

RUN cp /usr/lib/x86_64-linux-gnu/gstreamer-1.0/libgstx264.so /opt/intel/openvino_2021.4.582/data_processing/dl_streamer/lib

USER openvino

WORKDIR /home/openvino

COPY . .

