#
# Table structure for table `feedbacks`
#
# Creation: Tue Apr 29 2014
# Last update:
#

USE `thebestplace`;

DROP TABLE `feedbacks`;

CREATE TABLE `feedbacks` (
`id` int(10) unsigned NOT NULL auto_increment,
`userid` int(10) unsigned NOT NULL default 0,
`device_id` varchar(64) NOT NULL default '',
`venueid` varchar(64) NOT NULL default '',
`venuename` varchar(256) NOT NULL default '',
`createdAt` int(10) unsigned NOT NULL default 0,
`photo_prefix` varchar(256) NOT NULL default '',
`photo_suffix` varchar(256) NOT NULL default '',
`rate` int(3) unsigned NOT NULL default 0,
`text` varchar(512) NOT NULL default '',
`name` varchar(128) NOT NULL default '',
`email` varchar(128) NOT NULL default '',
`feedbackid` varchar(128) NOT NULL default '',
`categoryid` varchar(128) NOT NULL default '',
PRIMARY KEY (`id`)
);

#
# Dumping data for table `feedbacks`
#

INSERT INTO `feedbacks` VALUES (1,
1,
'1234567890899999987776666',
1386404500,
'',
'',
'3',
'Cool!',
'Anonymous',
'',
0,
0
);

INSERT INTO `feedbacks` VALUES (2,
1,
'1234567890899999987776666',
1386404500,
'',
'',
'3',
'Bad',
'Anonymous',
'',
0,
0
);

INSERT INTO `feedbacks` VALUES (3,
1,
'1234567890899999987776666',
1386404500,
'',
'',
'3',
'Nice',
'Anonymous',
'',
0,
0
);
