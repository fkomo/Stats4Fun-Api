-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DROP TABLES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
drop table fun.PlayerStats;

drop table fun.Player;

drop table fun.Match;

drop table fun.EnumTeam;

drop table fun.EnumPlace;

drop table fun.EnumCompetition;

drop table fun.EnumMatchType;

drop table fun.EnumMatchResult;

drop table fun.EnumPlayerPosition;

drop table fun.EnumState;

-------------------------------------------------------------------------------------------------------------------------------------------
-- CREATE TABLES
-------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE fun.EnumState (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	primary key (Id)
);

CREATE TABLE fun.EnumTeam (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.EnumPlace (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.EnumCompetition (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.EnumMatchType (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.EnumMatchResult (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.Match (
	Id int NOT NULL auto_increment,
	MatchTypeId int NOT NULL,
	CompetitionId int NULL,
	PlaceId int NOT NULL,
	DateTime datetime NOT NULL,
	HomeTeamId int NOT NULL,
	AwayTeamId int NOT NULL,
	HomeTeamScore int NOT NULL,
	AwayTeamScore int NOT NULL,
	Win int NULL,
	Loss int NULL,
	Tie int NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (MatchTypeId) REFERENCES EnumMatchType(Id),
	FOREIGN KEY (CompetitionId) REFERENCES EnumCompetition(Id),
	FOREIGN KEY (PlaceId) REFERENCES EnumPlace(Id),
	FOREIGN KEY (HomeTeamId) REFERENCES EnumTeam(Id),
	FOREIGN KEY (AwayTeamId) REFERENCES EnumTeam(Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.EnumPlayerPosition (
	Id int NOT NULL auto_increment,
	Name nvarchar(100) NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.Player (
	Id int NOT NULL auto_increment,
	Name nvarchar(50) NOT NULL,
	Number int NULL,
	DateOfBirth date NULL,
	TeamId int NOT NULL,
	PlayerPositionId int NOT NULL,
	PlayerInfoId int NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (TeamId) REFERENCES EnumTeam(Id),
	FOREIGN KEY (PlayerPositionId) REFERENCES EnumPlayerPosition(Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);

CREATE TABLE fun.PlayerStats (
	Id int NOT NULL auto_increment,
	PlayerId int NOT NULL,
	MatchId int NOT NULL,
	Goals int NOT NULL,
	Assists int NOT NULL,
	PosNegPoints int NOT NULL,
	YellowCards int NOT NULL,
	RedCards int NOT NULL,
	StateId int NULL,
	primary key (Id),
	FOREIGN KEY (PlayerId) REFERENCES Player(Id),
	FOREIGN KEY (MatchId) REFERENCES fun.Match(Id),
	FOREIGN KEY (StateId) REFERENCES EnumState(Id)
);