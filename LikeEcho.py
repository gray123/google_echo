import speech_recognition as sr
from gtts import gTTS
import goslate
import wolframalpha
import os
from os import path
import re
import glob
import collections
import ntpath


# query Walfram-alpha search engine
def askWolframalpha(query):
  app_id = 'YV4XG4-KYWKHRV526'
  client = wolframalpha.Client(app_id)
  try:
    res = client.query(query)
    return next(res.results).text
  except:
    return 'I cannot find an answer'


# query Wiki engine
def askWiki(query):
  m = re.search('(?:)Qualcomm data(.)?center group(?:)', query)
  if m:
    return 'Oh, they build the best servers on this planet'
  else:
    return 'I cannot find an answer'


# sampler
def sampler():
  while True:
    os.system("sox -q -c 1 -r 16000 -t waveaudio 0 1.wav trim 0 1")

# one interactive transaction
# input: audio file
# output: play audio response
def OneTranscation(audio_file):
  # use file as source
  with sr.AudioFile(audio_file) as source
    print("Open " + audio_file)
    audio = r.record(source)
 
  try:
    # Speech recognition using Google Speech Recognition
    text_question = r.recognize_google(audio)
    print("Question: " + text_question)

    # the following if...elif...else is the central dispatcher
    # suppose "tell me about" or "give me instruction on"
    # are two designated key phrase to invoke Wiki
    m = re.search('(?:)(tell me about |give me instruction on )(.+)', text_question)
    if m:
      text_answer = askWiki(m.group(2))
    else:
      # default to ask Wolfram-alpha search engine
      text_answer = askWolframalpha(text_question)
    print("Answer: " +  text_answer)

    # Google translation
    #gs = goslate.Goslate()
    #text_answer = gs.translate(text_answer,'de')
    #lang_id = gs.detect(text_answer)
    #print("In " + gs.get_languages()[lang_id] + " " + text_answer)
    

    # Google Text To Speech API call
    tts = gTTS(text=text_answer, lang='en')
    tts.save("answer.mp3")

    # Play mp3 file with sox cmdline
    os.system("sox answer.mp3 -t waveaudio 0")
  except sr.UnknownValueError:
    print("Google Speech Recognition could not understand audio")
  except sr.RequestError as e:
    print("Could not request results from Google Speech Recognition service; {0}".format(e))



# Record Audio
#with sr.Microphone() as source:
#    print("Ask me anything...")
#    audio = r.listen(source)

# moving average
mv_avg_q = collections.deque(3*[0], 3)
mv_avg_q_size = 0
def mv_avg():
  return (mv_avg_q[0]+mv_avg_q[1]+mv_avg_q[2])/3



# main function
r = sr.Recognizer()
st = 'idle'
threshold = 0.1
startfilenum = -1
workdir = path.dirname(path.realpath(__file__))
tmpdir = path.join(workdir, "tmp")
while True:
    if len(glob.glob1(tmpdir, "*.wav")) > 3:
        # find the oldest audio file and get its size
        list_of_files = glob.glob(path.join(tmpdir,"*.wav"))
        oldest_file = min(list_of_files, key=path.getctime)
        filesize = path.getsize(oldest_file)
        if st == 'idle':
            if (mv_avg_q_size == 3) and (filesize > mv_avg()*(1.0 + threshold)):
                filenum = ntpath.basename(oldest_file).split(',')[0]
                startfilenum = filenum
                st = 'takecmd'
            else:
                mv_avg_q.append(filesize)
                os.remove(oldest_file)
        elif st == 'takecmd':
            if filesize < mv_avg()*(1.0 + threshold):
                audio_file = path.join(workdir,"question.wav")
                filenum = ntpath.basename(oldest_file).split('.')[0]
                cmd = "sox " + ' '.join(path.join(tmpdir,str(i)+".wav") for i in range(startfilenum, filenum)) + " " + audio_file
                os.system(cmd)
                OneTranscation(audio_file)
                st = 'idle'
        else:
            print('Wrong state: '+st)
            exit(1)
        if mv_avg_q_size < 3:
           mv_avg_q_size += 1
