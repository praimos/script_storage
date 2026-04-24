#!/usr/bin/env bash

if [ $@ ]; then
        psql -h 127.0.0.1 -p 5432 -U $1 -d postgres -c "\l"
else
        echo "Not enter user"
fi