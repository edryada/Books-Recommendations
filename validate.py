import csv
import re

expected_cols = 8
min_year = '1000'
max_year = '2005'

rows_total = 0
ok_rows = 0
skipped_rows = 0
warn_rows = 0

cleaned_rows = []  # store validated rows here

with open('Books.fixed.csv', encoding='utf-8') as file:
    reader = csv.DictReader(file, delimiter=",", quotechar='"')
    line_number = 0

    for cols in reader:
        line_number += 1
        rows_total += 1

        # check that line split has enough columns
        if len(cols) < expected_cols:
            print("ERR on line:", line_number, "Number of cols is", len(cols), "expected", expected_cols)
            skipped_rows += 1
            continue

        # extract columns
        isbn = cols["ISBN"].strip()
        title = cols["Book-Title"].strip()
        author = cols["Book-Author"].strip()
        year = cols["Year-Of-Publication"].strip()
        publisher = cols["Publisher"].strip()

        # --- start validation ---

        # ISBN: remove everything except letters and digits
        isbn = re.sub(r'[^A-Za-z0-9]', '', isbn)
        if not isbn:
            print("ERR on line:", line_number, "ISBN empty after cleanup")
            skipped_rows += 1
            continue

        # Title: must be non-empty
        if not title:
            print("WARN on line:", line_number, "Missing title")
            warn_rows += 1

        # Author: must be non-empty
        if not author:
            print("WARN on line:", line_number, "Missing author")
            warn_rows += 1

        # Year: must be 4 digits, within min/max year
        if len(year) > 4 or not year.isdigit():
            print("ERR on line:", line_number, "Year format invalid:", year, "SKIPPING")
            skipped_rows += 1
            continue
        elif year < min_year or year > max_year:
            warn_rows += 1
            year = ''  # clear invalid year but still keep row

        # Publisher: must be non-empty
        if not publisher:
            print("WARN on line:", line_number, "Missing publisher")
            warn_rows += 1

        ok_rows += 1

        # store the cleaned/validated row
        cleaned_rows.append({
            "isbn": isbn,
            "title": title,
            "author": author,
            "year": year,
            "publisher": publisher,
        })

# write validated rows to a new CSV
with open('Books.fixed.clean.csv', 'w', encoding='utf-8', newline='') as out_file:
    writer = csv.DictWriter(out_file, fieldnames=["isbn","title","author","year","publisher"])
    writer.writeheader()
    writer.writerows(cleaned_rows)

# print count of ok/err
print("Finished.")
print("Got", ok_rows, "OK rows", warn_rows, "WARN rows and", skipped_rows, "with ERR that were skipped.")
print(f"Validated rows written to Books.fixed.clean.csv ({len(validated_rows)} rows).")
