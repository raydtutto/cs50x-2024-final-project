import os
import re
import sys

def find_duplicate_uids(root_dir):
    uid_pattern = re.compile(r'uid="([^"]+)"')
    uid_counts = {}
    duplicates_found = False

    for dirpath, _, filenames in os.walk(root_dir):
        for filename in [f for f in filenames if f.endswith('.tscn')]:
            file_path = os.path.join(dirpath, filename)
            with open(file_path, 'r') as file:
                first_line = file.readline()
                match = uid_pattern.search(first_line)
                if match:
                    uid = match.group(1)
                    if uid in uid_counts:
                        uid_counts[uid].append(file_path)
                    else:
                        uid_counts[uid] = [file_path]

    for uid, paths in uid_counts.items():
        if len(paths) > 1:
            duplicates_found = True
            print(f" -> Duplicate UID found: {uid} in files:")
            for path in paths:
                print(f" --> {path}")

    return duplicates_found

def main():
    duplicates_found = find_duplicate_uids("./")
    print(duplicates_found)
    if duplicates_found:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
