#
# Table structure for table `users`
#
# Creation: Tue Apr 29 2014
# Last update:
#

USE `thebestplace`;

#DROP TABLE `users`;

CREATE TABLE `users` (
`id` int(10) unsigned NOT NULL auto_increment,
`userid` varchar(64) NOT NULL default '',
`contact` varchar(100) NOT NULL default '',
`firstname` varchar(128) NOT NULL default '',
`gender` varchar(5) NOT NULL default '',
`homeCity` varchar(128) NOT NULL default '',
`lastname` varchar(128) NOT NULL default '',
`photo_prefix` varchar(256) NOT NULL default '',
`photo_suffix` varchar(256) NOT NULL default '',
`email` varchar(128) NOT NULL default '',
`password` varchar(128) NOT NULL default '',
`name` varchar(128) NOT NULL default '',
`fb_id` varchar(64) NOT NULL default '',
`device_id` varchar(64) NOT NULL default '',
PRIMARY KEY (`id`)
);

#
# Dumping data for table `users`
#

INSERT INTO `users` VALUES (1,
'svmp@ukr.net',
'+380507200158',
'Sergey',
'M',
'Rossia',
'Krotkih',
'',
'',
'svmp@ukr.net',
'bTyuiiIii',
'Sergey Krotkih',
'1234567890899999987776666',
'123456789089999998777'
);

INSERT INTO `users` VALUES (2,
'svmp@ukr.net',
'+380507200158',
'Sergey',
'M',
'Rossia',
'Krotkih',
'',
'',
'svmp@ukr.net',
'123',
'Sergey Krotkih',
'1234567890899999987776666',
'123456789089999998777');

INSERT INTO `users` VALUES (3,
'svmp@ukr.net',
'+380507200158',
'Sergey',
'M',
'Rossia',
'Krotkih',
'',
'',
'svmp@ukr.net',
'321',
'Sergey Krotkih',
'1234567890899999987776666',
'123456789089999998777');

INSERT INTO `users` VALUES (4,
'svmp@ukr.net',
'+380507200158',
'Sergey',
'M',
'Rossia',
'Krotkih',
'',
'',
'svmp@ukr.net',
'777',
'Sergey Krotkih',
'1234567890899999987776666',
'123456789089999998777');
