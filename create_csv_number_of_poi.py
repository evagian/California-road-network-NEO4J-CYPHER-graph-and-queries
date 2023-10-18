import csv

file_path='./mapping.csv'    
has_poi=0
with open(file_path, 'r') as f:
    with open('has_number_of_poi.csv', 'w',newline='') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)
        csvwriter.writerow(['start_node','end_node','number_of_poi'])
        for line in f:
            data=line.strip().split(' ')
            if has_poi!=0:
                has_poi=0
                continue
            else: 
                has_poi=int(data[3])
                csvwriter.writerow([data[0],data[1], data[3] ]) 
                continue
