import re
import csv
import numpy as np
from scipy.interpolate import interp1d
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

    differences = []

    for subtitle_number, timing in provided_timings.items():
        est_diff = time_to_seconds(subtitle_times[subtitle_number]) - timing
        differences.append(est_diff)
   
    delta_diff = [differences[i] - differences[i-1] for i in range(1, len(differences))]
    timing=list(provided_timings.values())
    diff_timing=timing[1:]

    # Create the interpolation function
    f = interp1d(timing, differences)
    new_x = np.arange(time_to_seconds(subtitle_times[-1]))
    print(timing)
    print(len(new_x))
    est_error = f(new_x)
    # # Define the known data points
    # x = [3, 5, 10, 56, 345]
    # y = [1, 2, 3, 4, 5]
    # # Create the interpolation function
    # f = interp1d(x, y)
    # # Define the new x values
    # new_x = np.arange(1000)
    # # Interpolate the y values
    # new_y = f(new_x)


    # Plot the differences
    fig, axs = plt.subplots(2, 1)

    axs[0].plot(diff_timing, delta_diff, marker='o', linestyle='-')
    axs[0].grid(True)
    axs[0].set_title("Timing difference between samples")

    axs[1].plot(timing, differences, marker='x', linestyle='-')
    axs[1].grid(True)
    axs[1].set_title("Time error at sample places")

    plt.savefig('timeline.png')

if __name__ == "__main__":
    main()

