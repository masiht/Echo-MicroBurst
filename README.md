AT&T Echo Microburst project
=============================

The Echo Microburst is a speedometer using AT&T Echo server. The tests are a combination of Upload and Download. It performs upload/download tests with a delay as configured.
The EMB Server listens for packets on 2 different Ports. Each of the two ports is used for different purpose:

* Control Port (TCP): Control Port is used to establish a control channel between Client and Server using TCP protocol. Server listens for TCP connections from clients who wish to perform a test.

* Data Port (UDP): Server listens for Upload Burst packets on UDP Data Port. Server sends Upload Speed Information back to Client on TCP control port.

### Upload Test: 
In order to initiate an Upload test, Client should send a control packet to server on Control Port using TCP connection. 
After sending Control packet, Client should receive a packet from server on TCP port, which indicates that Server has received the Upload Test Request from Client. 
Once the confirmation packet is received from server on Control channel, Client should immediately send the burst of UDP Data. 
After sending the burst, Client should wait for the results of upload speed in Kilo Bytes per second on TCP control channel.

### Download Test: 
Client should send a control packet to server.
After sending Control packet, Client should immediately wait to receive the burst of UDP Data Packets from server.
Client should capture Time Stamp on receiving first packet (TS1) and then after receiving last packet (TSn). 
The timestamp precision should be correct up to microseconds as most the times a burst of 10 or 20 packets is received in few microseconds.
Client should use below formula to calculate the Download Speed.

Download Speed = ( (NoOfPackets -1) * PacketSize ) / (TSn – TS1)

==================================================================

Server Name: http://dallecholin101.att.com/  
Server IP Address: 108.229.9.53  
Server OS: Linux Ubuntu  

Microburst Download Server Process Port: 62121  
Microburst Upload Server Control Port: 62122   
Microburst Upload Server Data Port: 62123 

### Reference:  
[CocoaAsyncSocket](http://cocoapods.org/pods/CocoaAsyncSocket) provides easy-to-use and powerful asynchronous socket libraries for Mac and iOS.

### Author:
Masih  
Follow me on Twitter [@masihtl](https://twitter.com/masihtl).