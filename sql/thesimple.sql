Create database thegym;
Create Role thegym With Superuser;
Alter Role thegym With Login;
\c thegym

CREATE TABLE hrdata (id BIGINT, color text, location text, event_timestamp text, deviceid text, username text, heartrate INT, region text, PRIMARY KEY (id, region)) PARTITION BY LIST (region);

CREATE TABLE latesthrdata (id BIGINT, color text, location text, event_timestamp text, deviceid text, username text, heartrate INT, region text, PRIMARY KEY (username, region)) PARTITION BY LIST (region);

CREATE TABLE hrdata_emea 
    PARTITION OF hrdata 
    (id, color, location, event_timestamp, deviceid, username, heartrate, region)
    FOR VALUES IN ('EMEA');

CREATE TABLE hrdata_amer
    PARTITION OF hrdata 
    (id, color, location, event_timestamp, deviceid, username, heartrate, region)
    FOR VALUES IN ('AMER');

CREATE TABLE hrdata_apac 
    PARTITION OF hrdata 
    (id, color, location, event_timestamp, deviceid, username, heartrate, region)
    FOR VALUES IN ('APAC');

CREATE TABLE latesthrdata_emea 
    PARTITION OF latesthrdata 
    (id, color, location, event_timestamp, deviceid, username, heartrate, region)
    FOR VALUES IN ('EMEA');

CREATE TABLE latesthrdata_amer
    PARTITION OF latesthrdata 
    (id, color, location, event_timestamp, deviceid, username, heartrate, region)
    FOR VALUES IN ('AMER');

CREATE TABLE latesthrdata_apac 
    PARTITION OF latesthrdata 
    (id, color, location, event_timestamp, deviceid, username, heartrate, region)
    FOR VALUES IN ('APAC');

Insert into hrdata values (4711, '0x00FF00', '48.137154,11.576124', '1632389493615', 'my garmin', 'me',
120, 'EMEA');
Insert into hrdata values (4712, '0x808000', '37.775,-122.4183333', '1632389493615', 'my garmin', 'you',
120, 'AMER');
Insert into hrdata values (4713, '0xFF0000', '1.295078, 103.854570', '1632389493615', 'my garmin', 'it',
120, 'APAC');




