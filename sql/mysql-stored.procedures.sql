-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DROP STORED PROCEDURES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
drop procedure fun.ListEnumCompetitions;

drop procedure fun.ListEnumTeams;

drop procedure fun.ListEnumPlayerPositions;

drop procedure fun.ListEnumMatchTypes;

drop procedure fun.ListEnumMatchResults;

drop procedure fun.ListEnumPlaces;

drop procedure fun.ListEnumStates;

drop procedure fun.ListEnumPlayers;

drop procedure fun.ListSeasons;

drop procedure fun.ListMatches;

drop procedure fun.GetMatch;

drop procedure fun.InsertMatch;

drop procedure fun.ModifyMatch;

drop procedure fun.DeleteMatch;

drop procedure fun.MatchesStats;

drop procedure fun.ListMatchPlayerStats;

drop procedure fun.InsertMatchPlayerStats;

drop procedure fun.ModifyMatchPlayerStats;

drop procedure fun.DeleteMatchPlayerStats;

drop procedure fun.ListPlayerStats;

drop procedure fun.GetPlayer;

drop procedure fun.InsertPlayer;

drop procedure fun.ModifyPlayer;

drop procedure fun.DeletePlayer;

drop procedure fun.ListCompetitions;

drop procedure fun.TopPlayerGoals;

drop procedure fun.TopPlayerAssists;

drop procedure fun.TopPlayerPoints;

drop procedure fun.TopPlayerPosNegPoints;

drop procedure fun.BottomPlayerPosNegPoints;

drop procedure fun.TopTeamGoalsScored;

drop procedure fun.TopTeamGoalsTaken;

drop procedure fun.TopTeamScore;

drop procedure fun.BottomTeamScore;

drop procedure fun.AllSeasonsStats;

drop procedure fun.FixMatchWinLossTie;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATE STORED PROCEDURES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $ $

CREATE PROCEDURE fun.ListEnumStates() BEGIN
select
	*
from
	fun.EnumState;

END $ $ 

CREATE PROCEDURE fun.ListEnumCompetitions() BEGIN
select
	*
from
	fun.EnumCompetition
where
	(StateId is null);

END $ $

CREATE PROCEDURE fun.ListEnumTeams() BEGIN
select
	*
from
	fun.EnumTeam
where
	(StateId is null);

END $ $

CREATE PROCEDURE fun.ListEnumPlayerPositions() BEGIN
select
	*
from
	fun.EnumPlayerPosition
where
	(StateId is null);

END $ $

CREATE PROCEDURE fun.ListEnumMatchTypes() BEGIN
select
	*
from
	fun.EnumMatchType
where
	(StateId is null);

END $ $

CREATE PROCEDURE fun.ListEnumMatchResults() BEGIN
select
	*
from
	fun.EnumMatchResult
where
	(StateId is null);

END $ $

CREATE PROCEDURE fun.ListEnumPlaces() BEGIN
select
	*
from
	fun.EnumPlace
where
	(StateId is null);

END $ $

CREATE PROCEDURE fun.ListSeasons() BEGIN
select
	distinct YEAR(DateTime) Season
from
	fun.Match
where
	MONTH(DateTime) > 8
	and (StateId is null)
order by
	Season desc;

END $ $

CREATE PROCEDURE fun.ListEnumPlayers (in activeOnly bit) BEGIN
select
	Id,
	Name
from
	Player
where
	(
		activeOnly = 1
		and StateId is null
	)
	or (
		activeOnly = 0
		and (
			StateId is null
			or StateId <> 1
		)
	);

END $ $

CREATE PROCEDURE fun.ListMatches (
	in season int,
	in teamId int,
	in matchTypeId int,
	in competitionId int,
	in placeId int,
	in resultId int
) BEGIN
select
	m.Id,
	m.DateTime,
	matchType.Name,
	place.Name,
	competition.Name,
	homeTeam.Name,
	awayTeam.Name,
	m.HomeTeamScore,
	m.AwayTeamScore
from
	fun.Match as m
	inner join fun.EnumTeam as homeTeam on homeTeam.Id = m.HomeTeamId
	inner join fun.EnumTeam as awayTeam on awayTeam.Id = m.AwayTeamId
	inner join fun.EnumMatchType as matchType on matchType.Id = m.MatchTypeId
	inner join fun.EnumPlace as place on place.Id = m.PlaceId
	left join fun.EnumCompetition as competition on competition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
	and (matchType.StateId is null)
	and (place.StateId is null)
	and (competition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
	and (
		competitionId is null
		or competitionId = m.CompetitionId
	)
	and (
		placeId is null
		or placeId = m.PlaceId
	)
	and (
		matchTypeId is null
		or matchTypeId = m.MatchTypeId
	)
	and (
		season is null
		or (
			MONTH(m.DateTime) < 8
			and (YEAR(m.DateTime) - 1) = season
		)
		or (
			MONTH(m.DateTime) > 8
			and (YEAR(m.DateTime) = season)
		)
	)
	and (
		resultId is null
		or (
			resultId = 0
			and HomeTeamScore = AwayTeamScore
		)
		or (
			resultId = 1
			and (
				(
					homeTeam.Name like '4Fun%'
					and HomeTeamScore > AwayTeamScore
				)
				or (
					awayTeam.Name like '4Fun%'
					and AwayTeamScore > HomeTeamScore
				)
			)
		)
		or (
			resultId = -1
			and (
				(
					homeTeam.Name like '4Fun%'
					and HomeTeamScore < AwayTeamScore
				)
				or (
					awayTeam.Name like '4Fun%'
					and AwayTeamScore < HomeTeamScore
				)
			)
		)
	)
order by
	m.DateTime desc;

END $ $

CREATE PROCEDURE fun.GetMatch (in matchId int) BEGIN
select
	m.Id,
	m.DateTime,
	EnumMatchType.Name as MatchType,
	EnumPlace.Name as Place,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeam,
	awayTeam.Name as AwayTeam,
	m.HomeTeamScore,
	m.AwayTeamScore
from
	fun.Match m
	inner join EnumPlace on EnumPlace.Id = m.PlaceId
	inner join EnumMatchType on EnumMatchType.Id = m.MatchTypeId
	inner join EnumTeam as homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam as awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and m.Id = matchId;

END $ $

CREATE PROCEDURE fun.InsertMatch (
	in dateTime datetime,
	in matchTypeId int,
	in placeId int,
	in competitionId int,
	in homeTeamId int,
	in awayTeamId int,
	in homeTeamScore int,
	in awayTeamScore int,
	in win int,
	in loss int,
	in tie int
) BEGIN
insert into
	fun.Match (
		DateTime,
		HomeTeamId,
		AwayTeamId,
		HomeTeamScore,
		AwayTeamScore,
		MatchTypeId,
		PlaceId,
		CompetitionId,
		Win,
		Loss,
		Tie
	)
values
	(
		dateTime,
		homeTeamId,
		awayTeamId,
		homeTeamScore,
		awayTeamScore,
		matchTypeId,
		placeId,
		competitionId,
		win,
		loss,
		tie
	);

select
	SCOPE_IDENTITY() as Id;

END $ $

CREATE PROCEDURE fun.ModifyMatch (
	in matchId int,
	in dateTime datetime,
	in matchTypeId int,
	in placeId int,
	in competitionId int,
	in homeTeamId int,
	in awayTeamId int,
	in homeTeamScore int,
	in awayTeamScore int,
	in win int,
	in loss int,
	in tie int
) BEGIN
update
	fun.Match
set
	DateTime = dateTime,
	HomeTeamId = homeTeamId,
	AwayTeamId = awayTeamId,
	HomeTeamScore = homeTeamScore,
	AwayTeamScore = awayTeamScore,
	MatchTypeId = matchTypeId,
	PlaceId = placeId,
	CompetitionId = competitionId,
	Win = win,
	Loss = loss,
	Tie = tie
where
	Id = matchId;

select
	matchId as Id;

END $ $

CREATE PROCEDURE fun.DeleteMatch (in matchId int) BEGIN
update
	PlayerStats
set
	StateId = 1
where
	Id = matchId;

update
	fun.Match
set
	StateId = 1
where
	Id = matchId;

END $ $

CREATE PROCEDURE fun.MatchesStats (
	in season int,
	in teamId int,
	in matchTypeId int,
	in competitionId int,
	in placeId int,
	in resultId int
) BEGIN
select
	COUNT(*) as GamesPlayed,
	SUM(Win) as Wins,
	SUM(Loss) as Losses,
	SUM(Tie) as Ties,
	SUM(Win) * 3 + SUM(Tie) as Points
from
	fun.Match m
	inner join EnumTeam as homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam as awayTeam on awayTeam.Id = m.AwayTeamId
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
	and (
		competitionId is null
		or competitionId = m.CompetitionId
	)
	and (
		placeId is null
		or placeId = m.PlaceId
	)
	and (
		matchTypeId is null
		or matchTypeId = m.MatchTypeId
	)
	and (
		season is null
		or (
			MONTH(m.DateTime) < 8
			and (YEAR(m.DateTime) - 1) = season
		)
		or (
			MONTH(m.DateTime) > 8
			and (YEAR(m.DateTime) = season)
		)
	)
	and (
		resultId is null
		or (
			resultId = 0
			and HomeTeamScore = AwayTeamScore
		)
		or (
			resultId = 1
			and (
				(
					homeTeam.Name like '4Fun%'
					and HomeTeamScore > AwayTeamScore
				)
				or (
					awayTeam.Name like '4Fun%'
					and AwayTeamScore > HomeTeamScore
				)
			)
		)
		or (
			resultId = -1
			and (
				(
					homeTeam.Name like '4Fun%'
					and HomeTeamScore < AwayTeamScore
				)
				or (
					awayTeam.Name like '4Fun%'
					and AwayTeamScore < HomeTeamScore
				)
			)
		)
	);

END $ $

CREATE PROCEDURE fun.ListPlayerStats (
	in season int,
	in teamId int,
	in matchTypeId int,
	in placeId int,
	in playerPositionId int,
	in competitionId int,
	in playerId int
) BEGIN
select
	AVG(Player.Id),
	AVG(Player.Number),
	Player.Name,
	COUNT(*) as GamesPlayed,
	SUM(Goals) as Goals,
	SUM(Assists) as Assists,
	SUM(PosNegPoints) as PosNegPoints,
	SUM(Goals) + SUM(Assists) as Points,
	SUM(YellowCards) as YellowCards,
	SUM(RedCards) as RedCards,
	AVG(EnumPlayerPosition.Id) as PlayerPositionId,
	AVG(Team.Id) as TeamId,
	AVG(PlayerState.Id) as PlayerStateId,
	SUM(m.Win) as WinCount,
	SUM(m.Loss) as LossCount,
	SUM(m.Tie) as TieCount
from
	PlayerStats
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join fun.Match as m on m.Id = PlayerStats.MatchId
	inner join EnumTeam Team on Team.Id = Player.TeamId
	inner join EnumTeam HomeTeam on HomeTeam.Id = m.HomeTeamId
	inner join EnumTeam AwayTeam on AwayTeam.Id = m.AwayTeamId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumPlace on EnumPlace.Id = m.PlaceId
	left join EnumCompetition on EnumCompetition.Id = m.CompetitionId
	left join EnumState PlayerState on PlayerState.Id = Player.StateId
where
	(PlayerStats.StateId is null)
	and (
		Player.StateId is null
		or Player.StateId <> 1
	)
	and (m.StateId is null)
	and (Team.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumPlace.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		playerId is null
		or Player.Id = playerId
	)
	and (
		teamId is null
		or (
			Team.Id = teamId
			or HomeTeam.Id = teamId
			or AwayTeam.Id = teamId
		)
	)
	and (
		season is null
		or (
			MONTH(m.DateTime) < 8
			and (YEAR(m.DateTime) - 1) = season
		)
		or (
			MONTH(m.DateTime) > 8
			and (YEAR(m.DateTime) = season)
		)
	)
	and (
		placeId is null
		or m.PlaceId = placeId
	)
	and (
		matchTypeId is null
		or m.MatchTypeId = matchTypeId
	)
	and (
		playerPositionId is null
		or Player.PlayerPositionId = playerPositionId
	)
	and (
		competitionId is null
		or m.CompetitionId = competitionId
	)
group by
	Player.Name
order by
	Points desc;
END $ $

CREATE PROCEDURE fun.ListMatchPlayerStats (in matchId int) BEGIN
select
	Player.Id as PlayerId,
	PlayerStats.Id as PlayerStatsId,
	Player.Number,
	Player.Name,
	PlayerStats.Goals,
	PlayerStats.Assists,
	PlayerStats.PosNegPoints,
	PlayerStats.Goals + PlayerStats.Assists + PlayerStats.PosNegPoints as Points,
	PlayerStats.YellowCards,
	PlayerStats.RedCards,
	EnumPlayerPosition.Name as PlayerPosition,
	EnumTeam.Name as Team
from
	PlayerStats
	inner join fun.Match as m on m.Id = PlayerStats.MatchId
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumTeam on EnumTeam.Id = Player.TeamId
where
	(PlayerStats.StateId is null)
	and (m.StateId is null)
	and m.Id = matchId
order by
	Points desc;

END $ $

CREATE PROCEDURE fun.InsertMatchPlayerStats (
	in playerId int,
	in matchId int,
	in goals int,
	in assists int,
	in posNegPoints int,
	in yellowCards int,
	in redCards int
) BEGIN
insert into
	PlayerStats (
		Goals,
		Assists,
		PosNegPoints,
		YellowCards,
		RedCards,
		MatchId,
		PlayerId
	)
values
	(
		goals,
		assists,
		posNegPoints,
		yellowCards,
		redCards,
		matchId,
		playerId
	);

select
	SCOPE_IDENTITY() as Id;

END $ $

CREATE PROCEDURE fun.ModifyMatchPlayerStats (
	in playerStatsId int,
	in playerId int,
	in matchId int,
	in goals int,
	in assists int,
	in posNegPoints int,
	in yellowCards int,
	in redCards int
) BEGIN
update
	PlayerStats
set
	Goals = goals,
	Assists = assists,
	PosNegPoints = posNegPoints,
	YellowCards = yellowCards,
	RedCards = redCards,
	MatchId = matchId,
	PlayerId = playerId
where
	Id = playerStatsId;

select
	playerStatsId as Id;

END $ $

CREATE PROCEDURE fun.DeleteMatchPlayerStats (in playerStatsId int) BEGIN
update
	PlayerStats
set
	StateId = 1
where
	PlayerStats.Id = playerStatsId;

END $ $

CREATE PROCEDURE fun.GetPlayer (in playerId int) BEGIN
select
	Id,
	Name,
	Number,
	DateOfBirth,
	TeamId,
	PlayerPositionId,
	StateId
from
	Player
where
	Id = playerId;

END $ $

CREATE PROCEDURE fun.InsertPlayer (
	in dateofBirth datetime,
	in name nvarchar(50),
	in number int,
	in playerPositionId int,
	in teamId int
) BEGIN
insert into
	Player (
		DateOfBirth,
		TeamId,
		Name,
		Number,
		PlayerPositionId
	)
values
	(
		dateOfBirth,
		teamId,
		name,
		number,
		playerPositionId
	);

select
	SCOPE_IDENTITY() as Id;

END $ $

CREATE PROCEDURE fun.ModifyPlayer (
	in dateofBirth datetime,
	in name nvarchar(50),
	in number int,
	in playerPositionId int,
	in teamId int,
	in playerId int
) BEGIN
update
	Player
set
	DateOfBirth = dateOfBirth,
	TeamId = teamId,
	Name = name,
	Number = number,
	PlayerPositionId = playerPositionId
where
	Id = playerId;

select
	playerId as Id;

END $ $

CREATE PROCEDURE fun.DeletePlayer (in playerId int) BEGIN
update
	Player
set
	StateId = 1
where
	Player.Id = playerId;

END $ $

CREATE PROCEDURE fun.ListCompetitions (in season int) BEGIN
select
	distinct EnumCompetition.Name as Competition,
	EnumCompetition.Id
from
	fun.Match m
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		season is null
		or (
			MONTH(m.DateTime) < 8
			and (YEAR(m.DateTime) - 1) = season
		)
		or (
			MONTH(m.DateTime) > 8
			and (YEAR(m.DateTime) = season)
		)
	)
order by
	EnumCompetition.Id asc;

END $ $

CREATE PROCEDURE fun.TopPlayerGoals (in count int, in teamId int) BEGIN
select
	Player.Id as PlayerId,
	Player.Name as PlayerName,
	EnumPlayerPosition.Name as PlayerPosition,
	PlayerStats.Id as PlayerStatsId,
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeamName,
	awayTeam.Name as AwayTeamName,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	PlayerStats.Goals as Goals
from
	PlayerStats
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join fun.Match m on m.Id = PlayerStats.MatchId
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(PlayerStats.StateId is null)
	and (
		Player.StateId is null
		or Player.StateId <> 1
	)
	and (m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	Goals desc
limit
	count;

END $ $

CREATE PROCEDURE fun.TopPlayerAssists (in count int, in teamId int) BEGIN
select
	Player.Id as PlayerId,
	Player.Name as PlayerName,
	EnumPlayerPosition.Name as PlayerPosition,
	PlayerStats.Id as PlayerStatsId,
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeamName,
	awayTeam.Name as AwayTeamName,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	PlayerStats.Assists as Assists
from
	PlayerStats
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join fun.Match m on m.Id = PlayerStats.MatchId
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(PlayerStats.StateId is null)
	and (
		Player.StateId is null
		or Player.StateId <> 1
	)
	and (m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	Assists desc
limit
	count;

END $ $

CREATE PROCEDURE fun.TopPlayerPoints (in count int, in teamId int) BEGIN
select
	Player.Id as PlayerId,
	Player.Name as PlayerName,
	EnumPlayerPosition.Name as PlayerPosition,
	PlayerStats.Id as PlayerStatsId,
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeamName,
	awayTeam.Name as AwayTeamName,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	PlayerStats.Goals as Goals,
	PlayerStats.Assists as Assists,
	Goals + Assists as Points
from
	PlayerStats
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join fun.Match m on m.Id = PlayerStats.MatchId
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(PlayerStats.StateId is null)
	and (
		Player.StateId is null
		or Player.StateId <> 1
	)
	and (m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	Goals + Assists desc
limit
	count;

END $ $

CREATE PROCEDURE fun.TopPlayerPosNegPoints (in count int, in teamId int) BEGIN
select
	Player.Id as PlayerId,
	Player.Name as PlayerName,
	EnumPlayerPosition.Name as PlayerPosition,
	PlayerStats.Id as PlayerStatsId,
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeamName,
	awayTeam.Name as AwayTeamName,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	PlayerStats.PosNegPoints as PosNegPoints
from
	PlayerStats
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join fun.Match m on m.Id = PlayerStats.MatchId
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(PlayerStats.StateId is null)
	and (
		Player.StateId is null
		or Player.StateId <> 1
	)
	and (m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	PosNegPoints desc
limit
	count;

END $ $

CREATE PROCEDURE fun.BottomPlayerPosNegPoints (in count int, in teamId int) BEGIN
select
	Player.Id as PlayerId,
	Player.Name as PlayerName,
	EnumPlayerPosition.Name as PlayerPosition,
	PlayerStats.Id as PlayerStatsId,
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeamName,
	awayTeam.Name as AwayTeamName,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	PlayerStats.PosNegPoints as PosNegPoints
from
	PlayerStats
	inner join Player on Player.Id = PlayerStats.PlayerId
	inner join fun.Match m on m.Id = PlayerStats.MatchId
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlayerPosition on EnumPlayerPosition.Id = Player.PlayerPositionId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(PlayerStats.StateId is null)
	and (
		Player.StateId is null
		or Player.StateId <> 1
	)
	and (m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	PosNegPoints asc
limit
	count;

END $ $

CREATE PROCEDURE fun.TopTeamGoalsScored (in count int, in teamId int) BEGIN
select
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumMatchType.Name as MatchType,
	EnumPlace.Name as Place,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeam,
	awayTeam.Name as AwayTeam,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	case
		when homeTeam.Name like '4Fun%' then HomeTeamScore
		else AwayTeamScore
	end as OurScore
from
	fun.Match m
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlace on EnumPlace.Id = m.PlaceId
	inner join EnumMatchType on EnumMatchType.Id = m.MatchTypeId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlace.StateId is null)
	and (EnumMatchType.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	OurScore desc
limit
	count;

END $ $

CREATE PROCEDURE fun.TopTeamGoalsTaken (in count int, in teamId int) BEGIN
select
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumMatchType.Name as MatchType,
	EnumPlace.Name as Place,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeam,
	awayTeam.Name as AwayTeam,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	case
		when homeTeam.Name like '4Fun%' then AwayTeamScore
		else HomeTeamScore
	end as OpponentScore
from
	fun.Match m
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlace on EnumPlace.Id = m.PlaceId
	inner join EnumMatchType on EnumMatchType.Id = m.MatchTypeId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlace.StateId is null)
	and (EnumMatchType.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	OpponentScore desc
limit
	count;

END $ $

CREATE PROCEDURE fun.TopTeamScore (in count int, in teamId int) BEGIN
select
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumMatchType.Name as MatchType,
	EnumPlace.Name as Place,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeam,
	awayTeam.Name as AwayTeam,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	case
		when homeTeam.Name like '4Fun%' then HomeTeamScore - AwayTeamScore
		else AwayTeamScore - HomeTeamScore
	end as ScoreDiff
from
	fun.Match m
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlace on EnumPlace.Id = m.PlaceId
	inner join EnumMatchType on EnumMatchType.Id = m.MatchTypeId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlace.StateId is null)
	and (EnumMatchType.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	ScoreDiff desc
limit
	count;

END $ $

CREATE PROCEDURE fun.BottomTeamScore (in count int, in teamId int) BEGIN
select
	m.Id as MatchId,
	m.DateTime as MatchDateTime,
	EnumMatchType.Name as MatchType,
	EnumPlace.Name as Place,
	EnumCompetition.Name as Competition,
	homeTeam.Name as HomeTeam,
	awayTeam.Name as AwayTeam,
	m.HomeTeamScore as HomeTeamScore,
	m.AwayTeamScore as AwayTeamScore,
	case
		when homeTeam.Name like '4Fun%' then HomeTeamScore - AwayTeamScore
		else AwayTeamScore - HomeTeamScore
	end as ScoreDiff
from
	fun.Match m
	inner join EnumTeam homeTeam on homeTeam.Id = m.HomeTeamId
	inner join EnumTeam awayTeam on awayTeam.Id = m.AwayTeamId
	inner join EnumPlace on EnumPlace.Id = m.PlaceId
	inner join EnumMatchType on EnumMatchType.Id = m.MatchTypeId
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlace.StateId is null)
	and (EnumMatchType.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
order by
	ScoreDiff asc
limit
	count;

END $ $

CREATE PROCEDURE fun.AllSeasonsStats (in teamId int) BEGIN
select
	case
		when (MONTH(m.DateTime) < 7) then (YEAR(m.DateTime) - 1)
		else YEAR(m.DateTime)
	end as Season,
	COUNT(*) as GamesPlayed,
	SUM(Win) as Wins,
	SUM(Loss) as Losses,
	SUM(Tie) as Ties,
	SUM(Win) * 3 + SUM(Tie) as Points,
	case
		when (teamId is null) then null
		else AVG(EnumCompetition.Id)
	end as CompetitionId
from
	fun.Match m
	inner join EnumCompetition on EnumCompetition.Id = m.CompetitionId
where
	(m.StateId is null)
	and (EnumCompetition.StateId is null)
	and (
		teamId is null
		or teamId = m.HomeTeamId
		or teamId = m.AwayTeamId
	)
group by
	case
		when (MONTH(m.DateTime) < 7) then (YEAR(m.DateTime) - 1)
		else YEAR(m.DateTime)
	end
order by
	Season desc;

END $ $

CREATE PROCEDURE fun.FixMatchWinLossTie() BEGIN
update
	fun.Match m
	inner join fun.EnumTeam h on m.HomeTeamId = h.Id
	inner join fun.EnumTeam a on m.AwayTeamId = a.Id
set
	Win = CASE
		WHEN (
			HomeTeamScore > AwayTeamScore
			and h.Name like '4Fun%'
		) THEN 1
		WHEN (
			HomeTeamScore < AwayTeamScore
			and a.Name like '4Fun%'
		) THEN 1
		ELSE 0
	END,
	Loss = CASE
		WHEN (
			HomeTeamScore > AwayTeamScore
			and a.Name like '4Fun%'
		) THEN 1
		WHEN (
			HomeTeamScore < AwayTeamScore
			and h.Name like '4Fun%'
		) THEN 1
		ELSE 0
	END,
	Tie = CASE
		WHEN (HomeTeamScore = AwayTeamScore) THEN 1
		ELSE 0
	END;

END $ $

DELIMITER ;