#!/usr/bin/python
import sys, re
import wolframalpha

def askWolframalpha(query):
  app_id = 'YV4XG4-KYWKHRV526'
  client = wolframalpha.Client(app_id)
  try:
    res = client.query(query)
    podslist = list(res.pods)
    txt = podslist[1].text.encode('utf-8','ignore')
    return txt
  except:
    return 'I cannot find an answer'

def askWiki(query):
  m = re.search('(?:)qualcomm data(.)?center group(?:)', query)
  if m:
    return m.group(0)+' builds the best servers'
  else:
    return 'I cannot find an answer'

if len(sys.argv) != 2:
  print "Usage:./"+sys.argv[0]+" inputfile\n"
  exit(1)

try:
  fp = open(sys.argv[1],'r')
  oneline = fp.read().lower()
  #special case some sentence to invoke an app
  m = re.search('(?:)(tell me about |give me instruction on )(.+)', oneline)
  if m:
    print askWiki(m.group(2))

  #no app is used, default to Wolfram-alpha
  print askWolframalpha(query)
except:
  print ""
