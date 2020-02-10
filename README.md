
# WalkTalk

The purpose of this project is to create a walkie talkie chatting app that would operate in local network using iOS Bonjour networking technique.

# Demo Video
https://github.com/SylvainChan/WalkTalk/releases/download/1.0.0/Demo.wk.m4v

# Try the app
Simply download the source project and compile it in XCode 11.3.1.

# Features Checklist
 - [x] Previous connection info caching, avoid the need of reentering everything
 - [x] App user can specify a self-defined channel id for the chatroom to avoid chatroom easily search by others
 - [x] User can change their desire display name in the chatroom
 - [x] User can receive remote push notification when they put app in background
 - [x] Multiple peers chatroom
 - [x] No actual host/server require, can use without WAN network
 - [x] Notify chatroom members about new joiner / leaver
 - [x] Auto disconnect mechanism
 - [x] Predefined message, click to send
 - [x] Colourful UI

## Requirement checklist
 - [x] An app user is able to search for any nearby app users, then initialize a real time chat/ chat room.
 - [x] A user should be able to specify a nickname for the chats.
 - [x] A chat/chat room allows more than 2 participants, thus a group chat.
 - [x] Users in a chat room can talk to each other by text
 - [x] A list of greeting messages with click-to-send button, such as ‘Hello’, ‘How are you’, etc.
 - [ ] Supports Multimedia such as image and voice
 - [x] Supports Push Notification
 - [x] Proper Testing cases
 - [x] Nice looking User Interface

# The Network
This section will discuss about the technical part focus on network part of this project

## **Connection**

 This project makes use of **[MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)**  . 
> The Multipeer Connectivity Framework provides a layer on top of Bonjour that lets you communicate with apps running on nearby devices (over infrastructure Wi-Fi, peer-to-peer Wi-Fi, and either Bluetooth (for iOS) or Ethernet (for OS X) without having to write lots of networking code specific to your app.

It requires no WAN network connection, and support up to 7-peer connections using following means:
 1. Wi-Fi
 2. Bluetooth

## **Socket**

MultipeerConnectivity is a layer on top of Bonjour. Peers within Bonjour network exchange data using UDP and TCP, which are the protocols defined for socket to do data exchange.

## **Host**

![enter image description here](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/NetServices/Art/bonjour_intro_2x.png)

There is no centralized host in this network. This is a mesh-like connection, every one within the network retains connection between others peer with same service name

## **Nickname and ID**

In this app, we have the following

 1. **MCPeerID** 
 
	 This is a native object that can be used a the user/peer id
	 
 2. **Sender**
 
	 We defined this entitly on our own. This object can let us define user desired name to be displayed to other in the chat room.

Changing sender name of the peer will not alter the value / reference of ID of the user.

## Handshake
In order to let peers in the same network knows each other, we develop a handshake mechanism. 
We define the messages into several types. Not every message need to display to user.

| Type | Usage | Receiver handling |
|--|--|--|
| greeting | A greeting message send to all peers in the network. To synchronize user's ID and display nickname. |Display notice of new joiner name|
| requestIdentity | A message to request all peers in the network to 'introduce' themselves. i.e. tell them send greeting message once again |Send greeting message and devicetoken to the network|
| message | Real message sent by user |Show message|
| deviceToken | A message containing the sender's push token | cache the sender's push token in the mapping table |


# Connection status
| View | Connect to any peer? |Status |
|--|--|--|
| User enter chat room | X | Not connected |
| User enter chat room | V | Connected |
| User leave chat room | V | Not connected |
| User kill the app | V | Not connected |
| User put the app into background | V | Connected |
| User put the app into background | X | Not connected |

If user disconnected from the app,  a notice will be shown it the chatroom to let other know.

# Push Notification
**Prerequisite**
User allow app to receive notification

Push notification is available in this app. Only when user is connected to the app will the app treat that user is in the chatroom and send notification to them when necessary.

# Background Mode
This app support background process, which can allow user receive message (both F/E and remote push notification) even the app is not on foreground, for a limited period of time controlled by native. After the background thread is being stopped, the user will be treated as disconnected and will not be able to receive any new message push notification.

# To Be Added
Due to limited time, the MVP of the product supports only text exchange. In the future, we planned to add following features and quality enhancements:

 - [ ] Add more unit test cases
 - [ ] Support multimedia transfer
 - [ ] Timestamp and sync mechanism
 - [ ] Streaming (e.g. voice)
 - [ ] Auto reconnect
