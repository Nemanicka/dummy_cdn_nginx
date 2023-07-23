do_exit () {
    docker compose down
    sleep 3
    exit 1
}

call_nginx() {
    curl -v http://127.0.0.1:8080/nginx_ok_$1.jpg -o /dev/null &> curl_log

    HIT=$(grep "X-Cache-Status: $2" curl_log )
    if [[ -z "$HIT" ]]; then
        echo "No $2 header during call #$3 $1 response... fail!"
        do_exit
    fi
}

sudo rm -rf nginx/cache/*
docker compose up &

sleep 3

call_nginx "dog" "MISS" "1"
call_nginx "dog" "MISS" "2"
call_nginx "dog" "HIT" "3"

call_nginx "cat" "MISS" "1"
call_nginx "cat" "MISS" "2"
call_nginx "cat" "HIT" "3"

# Purge poor doggo, leave cat cache intact
curl -v http://127.0.0.1:8080/purge//nginx_ok_dog.jpg &> /dev/null

# Check doggo is purged
call_nginx "dog" "MISS" "4"

#Check cat is cached
call_nginx "cat" "HIT" "4"

echo "SUCCESS"
do_exit
