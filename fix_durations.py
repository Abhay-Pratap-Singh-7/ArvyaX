import json

durations = {
    "1": 109,
    "2": 120,
    "3": 30,
    "4": 49,
    "5": 16,
    "6": 26,
    "7": 31,
    "8": 26,
    "9": 30,
    "10": 16
}

with open("assets/data/ambiences.json", "r") as f:
    data = json.load(f)

for item in data:
    item["durationSeconds"] = durations[item["id"]]
    del item["durationMinutes"]

with open("assets/data/ambiences.json", "w") as f:
    json.dump(data, f, indent=2)

