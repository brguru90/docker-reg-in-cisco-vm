docker ps --format "table {{.Image}}" > imgs.txt

cat imgs.txt | while read line || [[ -n $line ]];
do
        echo -e "adding tag to image - $line"
        docker image tag $line xreasy-db-lnx.cisco.com/$line
done

cat imgs.txt | while read line || [[ -n $line ]];
do
        echo -e "pushing image - $line"
        docker push xreasy-db-lnx.cisco.com/$line
done