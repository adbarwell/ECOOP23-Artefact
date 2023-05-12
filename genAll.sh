#!/bin/bash

set -euo pipefail

for x in examples/*.nuscr;
do
  echo $x
  Teatrino -e -f $x
done
