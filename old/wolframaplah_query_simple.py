#!/usr/bin/python
import sys, urllib, urllib2, json

if len(sys.argv) != 2:
  usage='Usage: '+sys.argv[0]+' question_within_double_quotation_mark'
  print usage
else:
  querystr=urllib.quote_plus(sys.argv[1]);
  API_URL='http://api.wolframalpha.com/v2/query?input='+querystr+'&appid=YV4XG4-KYWKHRV526&podindex=1&output=json'
  res=json.load(urllib2.urlopen(API_URL))
  if res[u"queryresult"][u"success"]:
    try:
      print res[u"queryresult"][u"pods"][0][u"subpods"][0][u"plaintext"]
    except ValueError:
      print 'I cannot find an answer for that'
  else:
    print 'I cannot find an answer for that'
