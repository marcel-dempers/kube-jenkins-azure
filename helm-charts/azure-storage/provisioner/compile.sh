#!/bin/bash

cat provision.sh | gzip -cf | base64 | tr -d '\n' > provision.sh.min