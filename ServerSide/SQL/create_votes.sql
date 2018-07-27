#
# Table structure for table `feedbacks`
#
# Creation: Tue Apr 29 2014
# Last update:
#

USE `thebestplace`;

#DROP TABLE `votes`;

CREATE TABLE `votes` (
`id` int(10) unsigned NOT NULL auto_increment,
`createdAt` int(10) unsigned NOT NULL default 0,
`feedbackid` int(10) unsigned NOT NULL default 0,
`userid` int(10) unsigned NOT NULL default 0,
`device_id` varchar(64) NOT NULL default '',
`venueid` varchar(64) NOT NULL default '',
`vote` int(1) unsigned NOT NULL default 0,
PRIMARY KEY (`id`)
);

#
# Dumping data for table `votes`
#

INSERT INTO `votes` VALUES (1,
123456778899,
1,
1,
'1234567890899999987776666',
'1234567890899999987776666',
0
);
