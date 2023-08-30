import re
import csv
import numpy as np
import matplotlib.pyplot as plt

# Function to parse SRT file and extract subtitle start times
def parse_srt_file(srt_filename):
    with open(srt_filename, 'r', encoding='utf-8') as srt_file:
        srt_content = srt_file.read()
    
    subtitle_pattern = r'(\d+)\n(\d{2}:\d{2}:\d{2},\d{3}) --> \d{2}:\d{2}:\d{2},\d{3}'
    matches = re.findall(subtitle_pattern, srt_content)
    
    subtitle_numbers, start_times = zip(*matches)
    return start_times

# Function to convert time strings to seconds
def time_to_seconds(time_str):
    h, m, s = map(float, time_str.replace(',', '.').split(':'))
    return h * 3600 + m * 60 + s

# Function to read CSV file and extract provided timings
def read_csv_file(csv_filename):
    subtitle_timings = {}
    with open(csv_filename, 'r', newline='', encoding='utf-8') as csv_file:
        csv_reader = csv.reader(csv_file)
        for row in csv_reader:
            subtitle_number, timing = int(row[0]), row[1]
            subtitle_timings[subtitle_number] = time_to_seconds(timing)
    return subtitle_timings

# Main function
def main():
    srt_filename = 'your_subtitle.srt'  # Replace with your SRT file
    csv_filename = 'provided_timings.csv'  # Replace with your CSV file

    subtitle_times = parse_srt_file(srt_filename)
    provided_timings = read_csv_file(csv_filename)

    differences = [0]*len(provided_timings)

    for subtitle_number, timing in provided_timings.items():
        differences.append(time_to_seconds(subtitle_times[subtitle_number]) - timing)
    
    # Plot the differences
    plt.plot(differences, marker='o', linestyle='-')
    plt.xlabel('Subtitle Number')
    plt.ylabel('Time Difference (seconds)')
    plt.title('Time Difference Between SRT and Provided Timings')
    plt.grid(True)
    plt.savefig('timeline.png')

if __name__ == "__main__":
    main()

