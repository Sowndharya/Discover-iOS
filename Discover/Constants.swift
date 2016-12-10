//
//  Constants.swift
//  Discover
//
//  Created by Sowndharya on 19/11/16.
//  Copyright © 2016 Sowndharya. All rights reserved.
//

import Foundation


let SIGNUP_VIEW_CONTROLLER              = "SignupViewController"    //  String
let LOGIN_VIEW_CONTROLLER               = "LoginViewController"     //  String

/* Installation */
let PF_INSTALLATION_CLASS_NAME			= "_Installation"           //	Class name
let PF_INSTALLATION_OBJECTID			= "objectId"				//	String
let PF_INSTALLATION_USER				= "user"					//	Pointer to User Class

/* User */
let PF_USER_CLASS_NAME					= "_User"                   //	Class name
let PF_USER_OBJECTID					= "objectId"				//	String
let PF_USER_USERNAME					= "username"				//	String
let PF_USER_PASSWORD					= "password"				//	String
let PF_USER_EMAIL						= "email"                   //	String
let PF_USER_EMAILCOPY					= "emailCopy"               //	String
let PF_USER_FULLNAME					= "fullname"				//	String
let PF_USER_FULLNAME_LOWER				= "fullname_lower"          //	String
let PF_USER_PICTURE						= "picture"                 //	File
let PF_USER_THUMBNAIL					= "thumbnail"               //	File
let PF_USER_LOCATION                    = "location"                //  GeoPoint
let PF_USER_WANTS_TO_TEACH              = "wantsToTeach"            //  String
let PF_USER_WANTS_TO_LEARN              = "wantsToLearn"            //  String

let PF_USER_LOCALITY                    = "locality"                //  String
let PF_USER_POSTAL_CODE                 = "postalCode"              //  String
let PF_USER_ADMINISTRATIVE_AREA         = "administrativeArea"      //  String
let PF_USER_COUNTRY                     = "country"                 //  String

/* Chat */
let PF_CHAT_CLASS_NAME					= "Chat"					//	Class name
let PF_CHAT_USER						= "user"					//	Pointer to User Class
let PF_CHAT_GROUPID						= "groupId"                 //	String
let PF_CHAT_TEXT						= "text"					//	String
let PF_CHAT_PICTURE						= "picture"                 //	File
let PF_CHAT_VIDEO						= "video"                   //	File
let PF_CHAT_CREATEDAT					= "createdAt"               //	Date

/* Messages*/
let PF_MESSAGES_CLASS_NAME				= "Messages"				//	Class name
let PF_MESSAGES_USER					= "user"					//	Pointer to User Class
let PF_MESSAGES_GROUPID					= "groupId"                 //	String
let PF_MESSAGES_DESCRIPTION				= "description"             //	String
let PF_MESSAGES_LASTUSER				= "lastUser"				//	Pointer to User Class
let PF_MESSAGES_LASTMESSAGE				= "lastMessage"             //	String
let PF_MESSAGES_COUNTER					= "counter"                 //	Number
let PF_MESSAGES_UPDATEDACTION			= "updatedAction"           //	Date

/* Notification */
let NOTIFICATION_APP_STARTED			= "NCAppStarted"
let NOTIFICATION_USER_LOGGED_IN			= "NCUserLoggedIn"
let NOTIFICATION_USER_LOGGED_OUT		= "NCUserLoggedOut"
