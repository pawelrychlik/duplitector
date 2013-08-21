duplitector
===========

A duplicate data detector engine based on Elasticsearch. It's been successfully used as a proof of concept, piloting an full-blown enterprize solution.

Context
=======

In certain systems we have to deal with lots of low-quality data, containing some typos, malformatted or missing fields, erraneous bits of information, sometimes coming from different sources, like careless humans, faulty sensors, multiple external data providers, etc. This kind of datasets often contain vast numbers of duplicate or similar entries. If this is the case - then these systems might struggle to deal with such unnatural, often unforeseen, conditions. It might, in turn, affect the quality of service delivered by the system.

This project is meant to be a playground for developing a deduplication algorithm, and is currently aimed at the domain of various sorts of organizations (e.g. NPO databases). Still, it's small and generic enough, so that it can be easily adjusted to handle other data schemes or data sources.

The repository contains a set of crafted organizations and their duplicates (partially fetched from [IRS](http://www.irs.gov/Charities-&-Non-Profits/Exempt-Organizations-Select-Check), partially intentionally modified, partially made up), so that it's convenient to test the algorithm's pieces.

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

Example output
==============

(Cut for the sake of brevity).

```
Processing: {"id"=>"00-2237333", "name"=>"Lincoln Loan Fund", "type"=>"SOUNK", "city"=>"Fayetteville", "state"=>"AR", "country"=>"United States", "gov_id1"=>"EIN:002237333", "group_id"=>"18"}
No potential duplicates found. Highest score: 
Created new organization: {"id"=>["00-2237333"], "name"=>["Lincoln Loan Fund"], "type"=>["SOUNK"], "city"=>["Fayetteville"], "state"=>["AR"], "country"=>["United States"], "gov_id1"=>["EIN:002237333"], "group_id"=>["18"], "es_id"=>99}

Processing: {"id"=>"01-0140283", "name"=>"Pine Grove Cemetery Association", "type"=>"EO", "city"=>"Brunswick", "state"=>"ME", "gov_id1"=>"EIN:010140283", "group_id"=>"48"}
Found potential duplicates. Highest score: 3.485476
Merged duplicates into an existing organization: {"id"=>["01-0140283", "01-0140283"], "name"=>["Pine Grove Cemetery Association", "Pine Grove Cemetery Association"], "type"=>["EO", "EO"], "city"=>["Brunswick", "Brunswick"], "state"=>["ME", "ME"], "gov_id1"=>["EIN:010140283", "EIN:010140283"], "group_id"=>["48", "48"], "country"=>["United States"], "es_id"=>66}

FAIL: "group_id"=>"98" assigned to  2 orgs.
OK: "group_id"=>"11" assigned to  1 orgs.
OK: "group_id"=>"10" assigned to  1 orgs.
Duplicate resolution: OK=99, FAIL=1, ERROR=0.

Done. Stats: Organizations created: 101, Organizations resolved as duplicates: 99
```

Useful resources on the subject of deduplication:
* [an article](http://zmievski.org/2011/03/duplicates-detection-with-elasticsearch) by [Andrei Zmievski](http://twitter.com/a)
