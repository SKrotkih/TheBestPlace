#
# Table structure for table `friends`
#
# Creation: Tue Apr 29 2014
# Last update:
#

USE `thebestplace`;

#DROP TABLE `friends`;

CREATE TABLE `friends` (
`id` int(10) unsigned NOT NULL auto_increment,
`userid` int(10) unsigned NOT NULL,
`friendid` int(10) unsigned NOT NULL,
PRIMARY KEY (`id`)
);

#
# Dumping data for table `friends`
#

INSERT INTO `friends` VALUES (1,1,2);
