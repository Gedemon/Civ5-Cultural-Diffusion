
UPDATE Controls SET HotKey = NULL WHERE Type = 'CONTROL_QUICK_SAVE'; -- To allow saving of table before quicksaving game
UPDATE Controls SET HotKey = NULL WHERE Type = 'CONTROL_SAVE_GROUP' or Type = 'CONTROL_SAVE_NORMAL'; -- To allow saving of table before saving game