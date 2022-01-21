#!/bin/bash

while true; do
    printf "\033c"
    declare -a containers_name=($(docker stats --no-stream --format 'table {{.Name}}' | sed -n '2,$p' | tr '\n' ' '))
    mkdir -p dockerstats
    for container_name in "${containers_name[@]}"; do
        container_stats=($(docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}' $container_name | sed -n '2,$p'))

        if [ -f dockerstats/$container_name.cpu_usage.docker.stats.log ]
        then
            max_cpu_value=$(cat dockerstats/$container_name.cpu_usage.docker.stats.log)
        else
            max_cpu_value="0"
        fi

        if [ -f dockerstats/$container_name.mem_usage.docker.stats.log ]
        then
            max_mem_value=$(cat dockerstats/$container_name.mem_usage.docker.stats.log)
        else
            max_mem_value="0"
        fi

        cpu_value="${container_stats[1]}"
        mem_value="${container_stats[2]}"

        if [[ "$max_cpu_value" < "$cpu_value" ]]
        then
            echo "$cpu_value" > dockerstats/$container_name.cpu_usage.docker.stats.log
        fi

        if [[ "$max_mem_value" < "$mem_value" ]]
        then
            echo "$mem_value" > dockerstats/$container_name.mem_usage.docker.stats.log
        fi

        echo "${container_stats[0]} CPU_MAX_USAGE: $(cat dockerstats/$container_name.cpu_usage.docker.stats.log) MEM_MAX_USAGE: $(cat dockerstats/$container_name.mem_usage.docker.stats.log)" > dockerstats/$container_name.resume_usage.docker.stats.log
        echo "$(cat dockerstats/$container_name.resume_usage.docker.stats.log)"
    done
    sleep 1
done
