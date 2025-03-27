import csv

# Read CSV
with open('dictionary.csv', mode='r') as infile:
    reader = csv.reader(infile)
    words = [row[0] for row in reader if len(row[0]) >= 4]

# Write filtered words to a new CSV file
with open('filtered_dictionary.csv', mode='w', newline='') as outfile:
    writer = csv.writer(outfile)
    for word in words:
        writer.writerow([word])
