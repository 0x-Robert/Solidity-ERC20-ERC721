#!/bin/bash

# 12339759df4cc66c804c6fd5fe6eb78de79a76d87726320782cf7d3672836059
docker network create cl-net


docker network connect cl-net cl-postgres


docker network connect cl-net chainlink

