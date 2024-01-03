#!/bin/sh
# file: speedtest.sh

# These values can be overwritten with env variables
LOOP="${LOOP:-false}"
LOOP_DELAY="${LOOP_DELAY:-300}"
DB_SAVE="${DB_SAVE:-false}"

# These values are all that's required for InfluxDB V2, add/replace in Docker
DB_HOST="${DB_HOST:-http://localhost:8086}"
DB_ADMIN_TOKEN="${DB_ADMIN_TOKEN:-uuid-like-val-from-influxdb2}"
DB_ORG="${DB_ORG:-domain.com}"
DB_BUCKET="${DB_BUCKET:-speedtest}"
	  
run_speedtest()
{
    DATE=$(date +%s)
    HOSTNAME=$(hostname)

    # Start speed test
    echo "Running a Speed Test..."
    JSON=$(speedtest --accept-license --accept-gdpr -f json)
    DOWNLOAD="$(echo $JSON | jq -r '.download.bandwidth')"
    UPLOAD="$(echo $JSON | jq -r '.upload.bandwidth')"
    PING="$(echo $JSON | jq -r '.ping.latency')"
    echo "Your download speed is $(($DOWNLOAD  / 125000)) Mbps ($DOWNLOAD Bytes/s)."
    echo "Your upload speed is $(($UPLOAD  / 125000)) Mbps ($UPLOAD Bytes/s)."
    echo "Your ping is $PING ms."

    # Save results in the database
    if $DB_SAVE; 
    then
		echo " "
        echo "Saving values to database..."
		echo " "
        
	    curl -s -S -X POST  "$DB_HOST/api/v2/write?org=$DB_ORG&bucket=$DB_BUCKET&precision=s" \
			--header "Authorization: Token $DB_ADMIN_TOKEN" \
			--header "Content-Type: text/plain; charset=utf-8" \
  		    --header "Accept: application/json" \
            --data-binary "download value=$DOWNLOAD $DATE"
		
        curl -s -S -X POST  "$DB_HOST/api/v2/write?org=$DB_ORG&bucket=$DB_BUCKET&precision=s" \
			--header "Authorization: Token $DB_ADMIN_TOKEN" \
			--header "Content-Type: text/plain; charset=utf-8" \
  		    --header "Accept: application/json" \
            --data-binary "upload value=$UPLOAD $DATE"
		
        curl -s -S -X POST  "$DB_HOST/api/v2/write?org=$DB_ORG&bucket=$DB_BUCKET&precision=s" \
			--header "Authorization: Token $DB_ADMIN_TOKEN" \
			--header "Content-Type: text/plain; charset=utf-8" \
  		    --header "Accept: application/json" \
            --data-binary "ping value=$PING $DATE"

		echo " "
        echo "Values saved."
    fi
}

if $LOOP;
then
    while :
    do
        run_speedtest
        echo "Running next test in ${LOOP_DELAY}s..."
        echo ""
        sleep $LOOP_DELAY
    done
else
    run_speedtest   
fi
