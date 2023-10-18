import csv

file_path='mapping.csv'    
has_poi=0
start_node_id='0'
with open(file_path, 'r') as f:
    with open('has_poi.csv', 'w',newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)
        csvwriter.writerow(['start_node','cat_id','distance'])
        for line in f:
            data=line.strip().split(' ')
            if has_poi!=0:
                for points in range(0,len(data),2):
                    csvwriter.writerow([start_node_id, data[points], data[points+1] ]) 
                has_poi=0
                continue
            else: 
                start_node_id=data[0]
                has_poi=int(data[3])
                continue
