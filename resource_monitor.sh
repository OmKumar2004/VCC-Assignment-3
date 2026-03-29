#!/bin/bash

UP_THRESHOLD=75
DOWN_THRESHOLD=30
COOLDOWN=60
LAST_TRIGGER=0
LOG_FILE="scaling.log"

ZONE="asia-south2-a"
INSTANCE_GROUP="om-a3-mig"
MAX_INSTANCES=5
MIN_INSTANCES=1

echo "Monitoring started..." >> $LOG_FILE

while true; do

    cpu_usage=$(top -bn1 | grep "Cpu(s)" | \
    sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
    awk '{print 100 - $1}')

    mem_usage=$(free | awk '/Mem:/ {print ($3/$2)*100}')

    timestamp=$(date)
    current_time=$(date +%s)

    echo "$timestamp | CPU: $cpu_usage% | MEM: $mem_usage%" >> $LOG_FILE

    INSTANCE_COUNT=$(gcloud compute instance-groups managed list-instances $INSTANCE_GROUP \
    --zone=$ZONE --format="value(instance)" | wc -l)

    # SCALE UP
    if (( $(echo "$cpu_usage > $UP_THRESHOLD" | bc -l) )) || \
       (( $(echo "$mem_usage > $UP_THRESHOLD" | bc -l) )); then

        if (( current_time - LAST_TRIGGER > COOLDOWN )); then
            if [ "$INSTANCE_COUNT" -lt "$MAX_INSTANCES" ]; then
                NEW_SIZE=$((INSTANCE_COUNT + 1))

                echo "$timestamp | Scaling UP to $NEW_SIZE" >> $LOG_FILE

                gcloud compute instance-groups managed resize $INSTANCE_GROUP \
                --size=$NEW_SIZE --zone=$ZONE

                LAST_TRIGGER=$current_time
            fi
        fi
    fi

    # SCALE DOWN
    if (( $(echo "$cpu_usage < $DOWN_THRESHOLD" | bc -l) )) && \
       (( current_time - LAST_TRIGGER > COOLDOWN )); then

        if [ "$INSTANCE_COUNT" -gt "$MIN_INSTANCES" ]; then
            NEW_SIZE=$((INSTANCE_COUNT - 1))

            echo "$timestamp | Scaling DOWN to $NEW_SIZE" >> $LOG_FILE

            gcloud compute instance-groups managed resize $INSTANCE_GROUP \
            --size=$NEW_SIZE --zone=$ZONE

            LAST_TRIGGER=$current_time
        fi
    fi

    sleep 10
done

