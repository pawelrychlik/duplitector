duplitector
===========

A duplicate data detector engine based on Elasticsearch. It's been successfully used as a proof of concept, piloting an full-blown enterprize solution.

Context
=======

In certain systems we have to deal with lots of low-quality data, containing some typos, malformatted or missing fields, erraneous bits of information, sometimes coming from different sources, like careless humans, faulty sensors, multiple external data providers, etc. This kind of datasets often contain vast numbers of duplicate or similar entries. If this is the case - then these systems might struggle to deal with such unnatural, often unforeseen, conditions. It might, in turn, affect the quality of service delivered by the system.

This project is meant to be a playground for developing a deduplication algorithm, and is currently aimed at the domain of various sorts of organizations (e.g. NPO databases). Still, it's small and generic enough, so that it can be easily adjusted to handle other data schemes or data sources.

The repository contains a set of crafted organizations and their duplicates (partially fetched from a handful of resources, partially intentionally modified, partially made up), so that it's convenient to test the algorithm's pieces.

How do I run this thing?
========================

Requires:
* ruby 1.9+ (tested on ruby 1.9.3) with ruby-gems
* 'stretcher' gem installed
* elasticsearch server running on localhost:9200 (configurable)

```
git clone https://github.com/pawelrychlik/duplitector.git
cd duplitector
gem install stretcher
ruby test.rb
```

For the time being, the configuration can be adjusted directly in `test.rb` (comments included).

Useful resources on the subject of deduplication:
* article by Andrei Zmievski: http://zmievski.org/2011/03/duplicates-detection-with-elasticsearch
