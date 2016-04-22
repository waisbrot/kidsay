#!python3

import csv
import sys
import re
import os.path

file_in = open(sys.argv[1], 'r') if len(sys.argv) > 1 else sys.stdin
data_in = file_in.read()
data_lines = data_in.split('\n')
table_in = csv.reader(data_lines, delimiter="\t")
entries = {}

class Post:
    def __init__(self, id, utc_date, post, title):
        self.id = id
        self.timestamp = '{} {}'.format(utc_date, '-0000')
        self.post = post.replace('\\n', '\n')
        self.title = title

        self.title_word = self.title.replace(' ', '-').replace(',', '').replace('.', '').replace('?', '').replace("'", '-')

        self.date = self.timestamp.split(' ')[0]

        self.filename = '{}-{}.md'.format(self.date, self.title_word)

        self.keywords = []
        for person in ['Carrie', 'Nate', 'Ezra', 'Phineas']:
            if person in self.post:
                self.keywords.append(person)

    def __gt__(self, other):
        return self.id > other.id

    def write(self, prefix):
        with open(os.path.join(prefix, self.filename), 'w') as outfile:
            outfile.write(
"""---
layout: post
title: {}
date: {}
categories:
tags:
{}
---
{}
""".format(self.title, self.timestamp, '\n'.join(['- {}'.format(T) for T in self.keywords]), self.post))

for row in table_in:
    if len(row) == 0:
        continue
    post = Post(id = row[0], utc_date = row[3], post = row[4], title = row[5])
    if post.title_word not in entries or entries[post.title_word] < post:
        entries[post.title_word] = post

prefix = '_posts'
os.makedirs(prefix, exist_ok=True)
for post in entries.values():
    post.write(prefix)

print("Done")
