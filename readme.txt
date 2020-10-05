docker stop stats4fun-api
docker rm stats4fun-api
docker image prune -a -f
docker build -t fkomo/stats4fun-api .
docker container stop stats4fun-api
docker run -d --name stats4fun-api -p 8081:8081 fkomo/stats4fun-api
