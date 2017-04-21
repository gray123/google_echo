#!/usr/bin/python
import wolframalpha
import sys

app_id='YV4XG4-KYWKHRV526'
client=wolframalpha.Client(app_id)

f=open(sys.argv[1],'r')
query=f.read()
try:
  res=client.query(query)
  podslist=list(res.pods)
  if len(podslist) > 0:
    texts=''
    pod=podslist[1]
    if pod.text:
      texts=pod.text
    else:
      texts='I cannot find an answer for that'
    texts=texts.encode('utf-8','ignore')
    print texts
  else:
    print 'Sorry, I am not sure'
except:
  print 'I cannot find an answer for that'
