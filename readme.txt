# stop/remove old & create/run new docker image
docker stop stats4fun-api
docker rm stats4fun-api
docker image prune -a -f
docker build -t fkomo/stats4fun-api .
docker run -d --name stats4fun-api -p 8081:8081 fkomo/stats4fun-api

# save
docker save -o stats4fun-api.dock.tar fkomo/stats4fun-api

#load/run image
sudo docker stop stats4fun-api
sudo docker rm stats4fun-api
sudo docker image prune -a -f
sudo docker load -i stats4fun-api.dock.tar
sudo docker run -d --name stats4fun-api -p 8081:8081 fkomo/stats4fun-api
