#!/bin/bash
python3 chaospy.py -dnew
python3 chaospy.py -dupd
unzip -o '*.zip'
rm *.zip
cat *.txt >> newdomains.md
rm *.txt
awk 'NR==FNR{lines[$0];next} !($0 in lines)' ../output/alltargets.txtls newdomains.md >> domains.txtls
echo Hourly scan result $(date +%F-%T) | notify 
echo "Total $(wc -l < domains.txtls) new domains found" | notify 
nuclei -ut
if [ -s ~/domains.txtls ]
then
        cat domains.txtls >> ../output/alltargets.txtls
        cat domains.txtls | httpx -fl 0 -mc 200 -threads 300 >> newurls.txtls
        echo "Total $(wc -l < newurls.txtls) live websites found" | notify 
        cat ../outout/alltargets.txtls | anew >> alltargets2.txtls
        rm ../output/alltargets.txtls
        mv alltargets2.txtls ../output/alltargets.txtls
        echo Below vulnerability $(date +%F-%T) | notify 
        echo "Starting nuclei"
        cat newurls.txtls | nuclei -t /root/nuclei-templates/ -silent -severity critical,high,medium -c 300 -H "User-Agent: Mozilla/5.0 Windows NT 10.0 Win64 AppleWebKit/537.36 Chrome/69.0.3497.100"| notify 
        echo "nuclei completed"
        rm newurls.txtls domains.txtls newdomains.md
else
        echo No new domains $(date +%F-%T) | notify 
        rm domains.txtls
        rm newdomains.md
fi
