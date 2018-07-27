#
# Table structure for table `mmnusers`
#
# Creation: Oct 19, 2014
# Last update:
#

USE `mmn`;

DROP TABLE `mmnusers`;

CREATE TABLE `mmnusers` (
`id` int(10) unsigned NOT NULL auto_increment,
`email` varchar(128) NOT NULL default '',
`password` varchar(128) NOT NULL default '',
`name` varchar(128) NOT NULL default '',
`username` varchar(128) NOT NULL default '',
PRIMARY KEY (`id`)
);

#
# Dumping data for table `users`
#

INSERT INTO `mmnusers` VALUES (1,
'svmp@ukr.net',
'123',
'Sergey Krotkih',
'stosha'
);
