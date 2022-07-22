import json
import sys

STEP = 500

if len(sys.argv) != 2:
    exit(f"Usage: {sys.argv[0]} <count>")

count = int(sys.argv[1])

output = {
    "names": [],
    "indexes": [],
    "starts": [],
    "ends": []
}

for i, start in enumerate(range(0, count, STEP), start=1):
    output["names"].append("sczps_no_peaks")
    output["indexes"].append(i)
    output["starts"].append(start)
    output["ends"].append(min(start + STEP, count) - 1)
with open("cwl.output.json", "w") as output_file:
    json.dump(output, output_file)