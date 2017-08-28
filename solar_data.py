import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
#from config import MQTT_TOPIC, MQTT_HOST, MQTT_PORT, MQTT_CLIENT
import csv
import time
#import datetime as dt
import datetime
import os, errno

FILE_NAME = 'data_recived.csv'
#subscribe to topics whichsends data
#MQTT_TOPIC = 'nodemcu/+/msg'
MQTT_TOPIC_1 = 'location1/east1/msg'
MQTT_TOPIC_2 = 'location1/east2/msg'
MQTT_TOPIC_3 = 'location1/east3/msg'
MQTT_TOPIC_4 = 'location1/east4/msg'
MQTT_TOPIC_5 = 'location1/east5/msg'
MQTT_TOPIC_6 = 'location1/east6/msg'

MQTT_HOST = '127.0.0.1'
MQTT_PORT = 1883
MQTT_CLIENT = 'san_nodemcu_temperature_data_collector_shaunak'

count = 00
#Global varibles
last_seq_no1 = 00001
last_seq_no2 = 00001
last_seq_no = []
for i in range(10):
    last_seq_no.append(00001)

#on connection with the broker subscribe for the topic with quality of service level 2
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))
    client.subscribe(MQTT_TOPIC_1, qos=2)
    client.subscribe(MQTT_TOPIC_2, qos=2)
    client.subscribe(MQTT_TOPIC_3, qos=2)
    client.subscribe(MQTT_TOPIC_4, qos=2)
    client.subscribe(MQTT_TOPIC_5, qos=2)
    client.subscribe(MQTT_TOPIC_6, qos=2)

#following code will be executed when a message is recived
def on_message(client, userdata, msg):
    global last_seq_no1
    global last_seq_no2
    global count
    global last_seq_no

    received_msg_topic = msg.topic
    
    #print "Current date is ", datetime.time.now()
    ts = time.time()
    currentTime = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S')
    print "Current time is " + str(currentTime)
    print "msg is " + msg.payload
    print type (msg.payload)

    received_msg = msg.payload.split(",")

    #Sync the msgs with the R Pi. If there is a difference of one minute then send the difference as ack
    print "RTC timestamp is ", received_msg[1]
    rtcMonth = received_msg[1][0:2]
    print "Month is ", rtcMonth
    rtcDay = received_msg[1][2:4]
    print "Day is ", rtcDay
    rtcHour = received_msg[1][4:6]
    print "Hour is ", rtcHour
    rtcMinute = received_msg[1][6:8]
    print "Minute is ", rtcMinute 
    flag=0
    
    ack_seq_no = msg.payload[0:5]
    print "Sequence number is " + ack_seq_no + " with type " 
    print type(ack_seq_no)
    #exception handling if some messages is not recived 
    #it will throw a error if he not able to convert ack_seq_no to integer    
    try:
         tobesend=int(ack_seq_no)
    except ValueError:
         print("******Not proper Integer******")
         flag=1
    count = count + 1
    today = datetime.date.today()
    print received_msg_topic
    print count

    if(flag==0):
    	if(tobesend>=0):
		received_topic = received_msg_topic.split("/")
		dirName = str(today) + "-" + received_topic[0]
		fileName = received_topic[1]
		try:
			os.makedirs(dirName)
		except OSError as e:
			if e.errno != errno.EEXIST:
				raise
		path = "/home/pi/Downloads/Sant_ap_mode/peer1/"+dirName

		#if(received_msg_topic=="nodemcu/peer1/msg"):
		#fileName = received_msg_topic.split("/")
		#try:
		#	os.makedir(fileName[0])
		#except OSError as e:
		#	if e.errno != errno.EEXIST:
		#		raise	
		print "location is " + dirName + "/" + fileName
		#str_last_seq_no1 = '%05d' %last_seq_no1
		str_last_seq_no = '%05d' % last_seq_no[int(fileName[-1])]
		print "string formated last seq no1 "+str_last_seq_no
		if(last_seq_no[int(fileName[-1])]+1 != tobesend) or (tobesend == 2600):
			if (tobesend == 2600):
				last_seq_no[int(fileName[-1])] = 0
				str_last_seq_no = '%05d' % last_seq_no[int(fileName[-1])]
		   		#publish.single("nodemcu/peer1/ack", "P1"+ack_seq_no, qos=2)
		   		publish.single(received_topic[0] + "/" + received_topic[1] + "/ack", "P1 "+ str_last_seq_no, qos=2)
		   		time.sleep(1)
		   		print("This is "+ fileName + " requested ack  " + str_last_seq_no)
			else:
				publish.single(received_topic[0] + "/" + received_topic[1] + "/ack", "P1 "+ str_last_seq_no, qos=2)
                                time.sleep(1)
                                print("This is "+ fileName + " requested ack  " + str_last_seq_no)
		else:
		   	last_seq_no[int(fileName[-1])] = tobesend
		    	#Following lines write the recivied messages in the file
			print("This is "+ fileName + " written to DIRECTORY " + dirName + str_last_seq_no)
			with open(os.path.join(path, (fileName+".csv")), "a") as statusFile:
				statusFileWriter = csv.writer(statusFile)
				statusFileWriter.writerow([int(time.time()), received_msg_topic, msg.payload])
			statusFile.close()
			#code_file_writer.writerow([int(time.time()),received_msg_topic,msg.payload])
			#code_file.flush()

		#if(received_msg_topic=="nodemcu/peer2/msg"):
		#	print "this is peer 2 "
		#	#fileName = received_msg_topic.split("/")
		#	print tobesend
		#	str_last_seq_no2 = '%05d' %last_seq_no2
		#	print "string formated last seq no2 "+str_last_seq_no2
		#	if(last_seq_no2+1 != tobesend):
		#		#publish.single("nodemcu/peer1/ack", "P2"+ack_seq_no, qos=2)
		#		publish.single("nodemcu/peer2/ack", "P2 "+ str_last_seq_no2, qos=2)
		#	    	print("This is peer 2 requested ack " + str_last_seq_no2)
		#	else:
		#	    	last_seq_no2 = tobesend
		#   		print("This is peer 1 written to file 222222222  " + str_last_seq_no2)
		#		#Following lines write the recivied messages in the file
		#		with open(os.path.join(path, (fileName[1]+".csv")), "a") as statusFile2:
		#			statusFileWriter2 = csv.writer(statusFile2)
		#			statusFileWriter2.writerow([int(time.time()), received_msg_topic, msg.payload])
		#		statusFile2.close()
		#   		#code_file_writer.writerow([int(time.time()),received_msg_topic,msg.payload])
		#	       	#code_file.flush()
			
	 	

#Following lines write the recivied messages in the file

#specify mqtt client name using which this client will  register at broker
client = mqtt.Client(MQTT_CLIENT+'CSV')
client.on_connect = on_connect
client.on_message = on_message

client.connect("localhost", MQTT_PORT, 60)
#code_file = open(FILE_NAME,'ab')
#code_file_writer = writer(code_file)
#code_file_writer.writerow(['timestamp','topic','code'])
client.loop_forever()
