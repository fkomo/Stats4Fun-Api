﻿-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
drop procedure fun.InsertTeam;
drop procedure fun.ModifyTeam;
drop procedure fun.InsertCompetition;
drop procedure fun.ModifyCompetition;
drop procedure fun.InsertMatchType;
drop procedure fun.ModifyMatchType;
drop procedure fun.InsertPlace;
drop procedure fun.ModifyPlace;
drop procedure fun.InsertPlayerPosition;
drop procedure fun.ModifyPlayerPosition;
drop procedure fun.InsertState;
drop procedure fun.ModifyState;
drop procedure fun.ModifyMatchResult;
drop procedure fun.ListMatchesByPlayerId;
drop procedure fun.ListPlayerStatsByPlayerId;
drop procedure fun.FixMatchWinLossTie; 
drop procedure fun.FixPlayers; 
drop procedure fun.GetPlayer;
drop procedure fun.InsertPlayer;
drop procedure fun.ModifyPlayer;
drop procedure fun.DeletePlayer;
drop procedure fun.ListPlayerSeasons;
drop procedure fun.ListMatches;
drop procedure fun.ListMutualMatches;
drop procedure fun.GetMatch;
drop procedure fun.InsertMatch;
drop procedure fun.ModifyMatch;
drop procedure fun.DeleteMatch;
drop procedure fun.ListPlayerStats;
drop procedure fun.ListMatchPlayerStats;
drop procedure fun.InsertPlayerStats;
drop procedure fun.DeletePlayerStats;
drop procedure fun.GetMVP;
drop procedure fun.ListMatchesWithMostGoalsScored;
drop procedure fun.ListMatchesWithMostGoalsTaken;
drop procedure fun.ListMatchesWithHighestScoreDiff;
drop procedure fun.ListMatchesWithLowestScoreDiff;
drop procedure fun.ListCardsInSeasons;
drop procedure fun.ListTeamStatsInSeasons;
drop procedure fun.ListPlayersWithMostHattricks;
drop procedure fun.ListMostGoalsCount;
drop procedure fun.ListPlayersWithGoals;

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

CREATE PROCEDURE fun.GetMatch (in matchId int) BEGIN
select
	m.Id,
	m.DateTime,
	m.MatchTypeId,
	m.PlaceId,
	m.CompetitionId,
	m.HomeTeamId,
	m.AwayTeamId,
	m.HomeTeamScore,
	m.AwayTeamScore
from
	fun.Match m
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
	in awayTeamScore int
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
		CompetitionId
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
		competitionId
	);

call fun.FixMatchWinLossTie();
call fun.GetMatch(LAST_INSERT_ID());

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
	in awayTeamScore int
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
	CompetitionId = competitionId
where
	Id = matchId;

call fun.FixMatchWinLossTie();
call fun.GetMatch(matchId);

END $ $

CREATE PROCEDURE fun.DeleteMatch (in matchId int) BEGIN

update
	fun.Match
set
	StateId = 1
where
	Id = matchId;

call fun.DeletePlayerStats(matchId);

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
	Id = playerId
	and (StateId is null or StateId <> 1);

END $ $

CREATE PROCEDURE fun.InsertPlayer (
	in dateofBirth datetime,
	in name nvarchar(100),
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

call fun.GetPlayer(LAST_INSERT_ID());

END $ $

CREATE PROCEDURE fun.ModifyPlayer (
	in playerId int,
	in dateofBirth datetime,
	in name nvarchar(100),
	in number int,
	in playerPositionId int,
	in teamId int,
	in stateId int
) BEGIN
update
	Player p
set
	p.DateOfBirth = dateOfBirth,
	p.TeamId = teamId,
	p.Name = name,
	p.Number = number,
	p.PlayerPositionId = playerPositionId,
    p.StateId = CASE WHEN stateId is null THEN p.StateId ELSE stateId END
where
	p.Id = playerId;

call fun.GetPlayer(playerId);

END $ $

CREATE PROCEDURE fun.DeletePlayer (in playerId int) BEGIN
update
	Player p
set
	p.StateId = 1
where
	p.Id = playerId;

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

CREATE PROCEDURE fun.FixPlayers() BEGIN
update
	fun.Player p
set
	p.StateId = 3
where 
	p.StateId is null;

END $ $

CREATE PROCEDURE fun.InsertTeam (
	in name varchar(100)
) BEGIN
insert into
	fun.EnumTeam (
		Name,
		StateId
	)
values
	(
		name,
		null
	);

select
	LAST_INSERT_ID() as Id;

END $ $

CREATE PROCEDURE fun.ModifyTeam (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumTeam t
set
	t.Name = name,
	t.StateId = stateId
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.InsertCompetition (
	in name varchar(100)
) BEGIN
insert into
	fun.EnumCompetition (
		Name,
		StateId
	)
values
	(
		name,
		null
	);

select
	LAST_INSERT_ID() as Id;

END $ $

CREATE PROCEDURE fun.ModifyCompetition (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumCompetition t
set
	t.Name = name,
	t.StateId = stateId
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.InsertMatchType (
	in name varchar(100)
) BEGIN
insert into
	fun.EnumMatchType (
		Name,
		StateId
	)
values
	(
		name,
		null
	);

select
	LAST_INSERT_ID() as Id;

END $ $

CREATE PROCEDURE fun.ModifyMatchType (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumMatchType t
set
	t.Name = name,
	t.StateId = stateId
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.InsertPlace (
	in name varchar(100)
) BEGIN
insert into
	fun.EnumPlace (
		Name,
		StateId
	)
values
	(
		name,
		null
	);

select
	LAST_INSERT_ID() as Id;

END $ $

CREATE PROCEDURE fun.ModifyPlace (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumPlace t
set
	t.Name = name,
	t.StateId = stateId
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.InsertPlayerPosition (
	in name varchar(100)
) BEGIN
insert into
	fun.EnumPlayerPosition (
		Name,
		StateId
	)
values
	(
		name,
		null
	);

select
	LAST_INSERT_ID() as Id;

END $ $

CREATE PROCEDURE fun.ModifyPlayerPosition (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumPlayerPosition t
set
	t.Name = name,
	t.StateId = stateId
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.InsertState (
	in name varchar(100)
) BEGIN
insert into
	fun.EnumState (
		Name
	)
values
	(
		name
	);

select
	LAST_INSERT_ID() as Id;

END $ $

CREATE PROCEDURE fun.ModifyState (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumState t
set
	t.Name = name
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.ModifyMatchResult (
	in id int,
	in name varchar(100),
	in stateId int
) BEGIN
update
	fun.EnumMatchResult t
set
	t.Name = name
where
	t.Id = id;

select
	Id;

END $ $

CREATE PROCEDURE fun.ListMatchesByPlayerId (
	in playerId int,
	in season int
) BEGIN
select
	m.Id,
	m.DateTime,
	m.MatchTypeId,
	m.PlaceId,
	m.CompetitionId,
	m.HomeTeamId,
	m.AwayTeamId,
	m.HomeTeamScore,
	m.AwayTeamScore,
	m.Win,
	m.Loss,
	m.Tie
from
	fun.PlayerStats as ps
	inner join fun.Match as m on m.Id = ps.MatchId
where
	(ps.StateId is null)
	and (m.StateId is null)
	and (ps.PlayerId = playerId)
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
	m.DateTime desc;

END $ $

CREATE PROCEDURE fun.ListPlayerStatsByPlayerId (
	in playerId int,
	in season int
) BEGIN
select
	ps.Id as PlayerStatsId,
	ps.PlayerId,
	m.Id as MatchId,
	ps.Goals,
	ps.Assists,
	ps.PosNegPoints,
	ps.YellowCards,
	ps.RedCards
from
	fun.PlayerStats as ps
	inner join fun.Match as m on m.Id = ps.MatchId
where
	(ps.StateId is null)
	and (m.StateId is null)
	and (ps.PlayerId = playerId)
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
	m.DateTime desc;

END $ $

CREATE PROCEDURE fun.ListPlayerSeasons(
	in playerId int
) BEGIN
select
	distinct YEAR(m.DateTime) Season
from
	fun.Match as m
	inner join fun.PlayerStats as ps on ps.MatchId = m.Id
where
	ps.PlayerId = playerId
	and ps.StateId is null
	and m.StateId is null
	and MONTH(m.DateTime) > 8
group by
	Season
order by
	Season desc;

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
	m.MatchtypeId,
	m.PlaceId,
	m.CompetitionId,
	m.HomeTeamId,
	m.AwayTeamId,
	m.HomeTeamScore,
	m.AwayTeamScore,
	m.Win,
	m.Loss,
	m.Tie
from
	fun.Match as m
	inner join fun.EnumTeam as homeTeam on homeTeam.Id = m.HomeTeamId
	inner join fun.EnumTeam as awayTeam on awayTeam.Id = m.AwayTeamId
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
			and m.HomeTeamScore = m.AwayTeamScore
		)
		or (
			resultId = 1
			and (
				(
					homeTeam.Name like '4Fun%'
					and m.HomeTeamScore > m.AwayTeamScore
				)
				or (
					awayTeam.Name like '4Fun%'
					and m.AwayTeamScore > m.HomeTeamScore
				)
			)
		)
		or (
			resultId = -1
			and (
				(
					homeTeam.Name like '4Fun%'
					and m.HomeTeamScore < m.AwayTeamScore
				)
				or (
					awayTeam.Name like '4Fun%'
					and m.AwayTeamScore < m.HomeTeamScore
				)
			)
		)
	)
order by
	m.DateTime desc;

END $ $

CREATE PROCEDURE fun.ListMutualMatches (
	in teamId1 int,
	in teamId2 int
) BEGIN
select
	m.Id,
	m.DateTime,
	m.MatchtypeId,
	m.PlaceId,
	m.CompetitionId,
	m.HomeTeamId,
	m.AwayTeamId,
	m.HomeTeamScore,
	m.AwayTeamScore,
	m.Win,
	m.Loss,
	m.Tie
from
	fun.Match as m
	inner join fun.EnumTeam as homeTeam on homeTeam.Id = m.HomeTeamId
	inner join fun.EnumTeam as awayTeam on awayTeam.Id = m.AwayTeamId
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
	and (
		(m.HomeTeamId = teamId1 and m.AwayTeamId = teamId2)
		or (m.HomeTeamId = teamId2 and m.AwayTeamId = teamId1)
	)
order by
	m.DateTime desc;

END $ $

CREATE PROCEDURE fun.ListPlayerStats (
	in season int,
	in teamId int,
	in matchTypeId int,
	in placeId int,
	in playerPositionId int,
	in competitionId int,
	in playerStateId int
) BEGIN
select
	AVG(Player.Id) as PlayerId,
	AVG(Player.Number) as PlayerNumber,
	MIN(Player.DateOfBirth) as DateOfBirth,
	Player.Name as Name,
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
	and ((playerStateId is null and (Player.StateId is null or Player.StateId <> 1))
		or (playerStateId is not null and Player.StateId = playerStateId)
	)
	and (m.StateId is null)
	and (Team.StateId is null)
	and (HomeTeam.StateId is null)
	and (AwayTeam.StateId is null)
	and (EnumPlayerPosition.StateId is null)
	and (EnumPlace.StateId is null)
	and (EnumCompetition.StateId is null)
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
	Player.Number as PlayerNumber,
	Player.Name,
	Player.PlayerPositionId,
	Player.TeamId,
	Player.DateOfBirth,
	Player.StateId as PlayerStateId,
	PlayerStats.Goals,
	PlayerStats.Assists,
	PlayerStats.PosNegPoints,
	(PlayerStats.Goals + PlayerStats.Assists) as Points,
	PlayerStats.YellowCards,
	PlayerStats.RedCards,
	matchId as MatchId
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

CREATE PROCEDURE fun.InsertPlayerStats (
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
	ps.PlayerId as PlayerId,
	ps.Id as PlayerStatsId,
	ps.MatchId as MatchId,
	p.Number as PlayerNumber,
	p.Name,
	p.PlayerPositionId,
	p.TeamId,
	p.StateId as PlayerStateId,
	ps.Goals,
	ps.Assists,
	ps.PosNegPoints,
	(ps.Goals + ps.Assists) as Points,
	ps.YellowCards,
	ps.RedCards
from
	PlayerStats as ps
    inner join Player as p on p.Id = ps.PlayerId
where
	ps.Id = LAST_INSERT_ID();

END $ $

CREATE PROCEDURE fun.DeletePlayerStats (in matchId int) BEGIN
update
	fun.PlayerStats ps
set
	ps.StateId = 1
where
	ps.MatchId = matchId;

END $ $

CREATE PROCEDURE fun.ListCardsInSeasons(
	in teamId int
) BEGIN
select
	(CASE WHEN MONTH(m.DateTime) < 8 THEN (YEAR(m.DateTime) - 1) ELSE YEAR(m.DateTime) END) as SeasonId,
   	SUM(ps.YellowCards) as YellowCards,
	SUM(ps.RedCards) as RedCards
from
	fun.Match m
	inner join fun.PlayerStats ps on m.Id = ps.MatchId
where
	(ps.StateId is null)
	and (m.StateId is null)
	and (teamId is null
		or (m.HomeTeamId = teamId or m.AwayTeamId = teamId))    
group by
	SeasonId
order by
	SeasonId asc;

END $ $

CREATE PROCEDURE fun.ListTeamStatsInSeasons(
	in teamId int
) BEGIN
select
	(CASE WHEN MONTH(m.DateTime) < 8 THEN (YEAR(m.DateTime) - 1) ELSE YEAR(m.DateTime) END) as SeasonId,
    COUNT(m.Id) as GamesPlayed,
    SUM(m.Win) as Wins,
    SUM(m.Loss) as Losses,
    SUM(m.tie) as Ties,
    SUM((CASE WHEN homeTeam.Name like '4Fun%' THEN m.HomeTeamScore ELSE m.AwayTeamScore END)) as GoalsFor,
	SUM((CASE WHEN awayTeam.Name like '4Fun%' THEN m.HomeTeamScore ELSE m.AwayTeamScore END)) as GoalsAgainst
from
	fun.Match m
	inner join fun.EnumTeam as homeTeam on m.HomeTeamId = homeTeam.Id
	inner join fun.EnumTeam as awayTeam on m.AwayTeamId = awayTeam.Id
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
	and (teamId is null
		or (m.HomeTeamId = teamId or m.AwayTeamId = teamId))
group by
	SeasonId
order by
	SeasonId asc;

END $ $

CREATE PROCEDURE fun.ListMostGoalsCount(
	in teamId int
) BEGIN
select
    ps.Goals as Goals,
    COUNT(*) as PlayerCount    
from
	fun.PlayerStats ps
    inner join fun.Player p on ps.PlayerId = p.Id
    inner join fun.Match m on ps.MatchId = m.Id
where
	(ps.StateId is null)
    and (m.StateId is null)
    and (p.StateId is null or p.StateId <> 1)
    and (teamId is null
		or (m.HomeTeamId = teamId or m.AwayTeamId = teamId))
group by
	Goals
order by
	Goals desc
limit 3;

END $ $

CREATE PROCEDURE fun.ListPlayersWithGoals(
	in goals int,
    in teamId int
) BEGIN
select
    ps.PlayerId as PlayerId,
    p.Name as PlayerName,
    ps.MatchId as MatchId,
    goals as Goals
from
	fun.PlayerStats ps
    inner join fun.Player p on ps.PlayerId = p.Id
    inner join fun.Match m on ps.MatchId = m.Id
where
	(ps.StateId is null)
    and (m.StateId is null)
    and (p.StateId is null or p.StateId <> 1)
    and (teamId is null
		or (m.HomeTeamId = teamId or m.AwayTeamId = teamId))
    and ps.Goals = goals
order by
	ps.PlayerId asc;

END $ $

CREATE PROCEDURE fun.ListPlayersWithMostHattricks(
	in teamId int
) BEGIN
select
    ps.PlayerId,
    p.Name as PlayerName,
    COUNT(*) as HattrickCount
from
	fun.PlayerStats ps
    inner join fun.Player p on ps.PlayerId = p.Id
    inner join fun.Match m on ps.MatchId = m.Id
where
	(ps.StateId is null)
    and (m.StateId is null)
    and (p.StateId is null or p.StateId <> 1)
    and (teamId is null or
		(m.homeTeamId = teamId or m.awayTeamId = teamId))
    and ps.Goals >= 3
group by
	ps.PlayerId
order by
	HattrickCount desc
limit 5;

END $ $

CREATE PROCEDURE fun.GetMVP(
	in seasonId int,
	in teamId int
) BEGIN
select
	AVG(p.Id) as PlayerId,
	AVG(p.Number) as PlayerNumber,
	MIN(p.DateOfBirth) as DateOfBirth,
	p.Name,
	COUNT(*) as GamesPlayed,
	SUM(ps.Goals) as Goals,
	SUM(ps.Assists) as Assists,
	SUM(ps.PosNegPoints) as PosNegPoints,
	SUM(ps.Goals) + SUM(Assists) as Points,
	SUM(ps.YellowCards) as YellowCards,
	SUM(ps.RedCards) as RedCards,
	AVG(p.PlayerPositionId) as PlayerPositionId,
   	AVG(p.TeamId) as TeamId,
    AVG(p.StateId) as PlayerStateId
from
	fun.PlayerStats ps
	inner join fun.Player p on p.Id = ps.PlayerId
	inner join fun.Match m on m.Id = ps.MatchId
where
	(ps.StateId is null)
	and (p.StateId is null or p.StateId <> 1)
	and (m.StateId is null)
	and ((MONTH(m.DateTime) < 8 and (YEAR(m.DateTime) - 1) = seasonId) 
		or (MONTH(m.DateTime) > 8 and (YEAR(m.DateTime) = seasonId)))
    and (teamId is null or
		(m.homeTeamId = teamId or m.awayTeamId = teamId))
group by
	p.Name
order by
	Points desc
limit 1;

END $ $

CREATE PROCEDURE fun.ListMatchesWithMostGoalsScored(
	in teamId int
) BEGIN
select
    m.Id,
    m.DateTime,
    m.MatchTypeId,
    m.PlaceId,
    m.CompetitionId,
    m.HomeTeamId,
    m.AwayTeamId,
    m.HomeTeamScore,
    m.AwayTeamScore,
    m.Win,
    m.Loss,
    m.Tie
from
	fun.Match m
	inner join fun.EnumTeam as homeTeam on m.HomeTeamId = homeTeam.Id
	inner join fun.EnumTeam as awayTeam on m.AwayTeamId = awayTeam.Id
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
    and (teamId is null
		or (homeTeam.Id = teamId or awayTeam.Id = teamId))
order by
	(CASE WHEN homeTeam.Name like '4Fun%' THEN m.HomeTeamScore ELSE m.AwayTeamScore END) desc
limit 3;

END $ $

CREATE PROCEDURE fun.ListMatchesWithMostGoalsTaken(
	in teamId int
) BEGIN
select
    m.Id,
    m.DateTime,
    m.MatchTypeId,
    m.PlaceId,
    m.CompetitionId,
    m.HomeTeamId,
    m.AwayTeamId,
    m.HomeTeamScore,
    m.AwayTeamScore,
    m.Win,
    m.Loss,
    m.Tie
from
	fun.Match m
	inner join fun.EnumTeam as homeTeam on m.HomeTeamId = homeTeam.Id
	inner join fun.EnumTeam as awayTeam on m.AwayTeamId = awayTeam.Id
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
    and (teamId is null
		or (homeTeam.Id = teamId or awayTeam.Id = teamId))
order by
	(CASE WHEN homeTeam.Name like '4Fun%' THEN m.AwayTeamScore ELSE m.HomeTeamScore END) desc
limit 3;

END $ $

CREATE PROCEDURE fun.ListMatchesWithHighestScoreDiff(
	in teamId int
) BEGIN
select
    m.Id,
    m.DateTime,
    m.MatchTypeId,
    m.PlaceId,
    m.CompetitionId,
    m.HomeTeamId,
    m.AwayTeamId,
    m.HomeTeamScore,
    m.AwayTeamScore,
    m.Win,
    m.Loss,
    m.Tie
from
	fun.Match m
	inner join fun.EnumTeam as homeTeam on m.HomeTeamId = homeTeam.Id
	inner join fun.EnumTeam as awayTeam on m.AwayTeamId = awayTeam.Id
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
    and (teamId is null
		or (homeTeam.Id = teamId or awayTeam.Id = teamId))
order by
	(CASE WHEN homeTeam.Name like '4Fun%' THEN m.HomeTeamScore - m.AwayTeamScore ELSE m.AwayTeamScore - m.HomeTeamScore END) desc
limit 3;

END $ $

CREATE PROCEDURE fun.ListMatchesWithLowestScoreDiff(
	in teamId int
) BEGIN
select
    m.Id,
    m.DateTime,
    m.MatchTypeId,
    m.PlaceId,
    m.CompetitionId,
    m.HomeTeamId,
    m.AwayTeamId,
    m.HomeTeamScore,
    m.AwayTeamScore,
    m.Win,
    m.Loss,
    m.Tie
from
	fun.Match m
	inner join fun.EnumTeam as homeTeam on m.HomeTeamId = homeTeam.Id
	inner join fun.EnumTeam as awayTeam on m.AwayTeamId = awayTeam.Id
where
	(m.StateId is null)
	and (homeTeam.StateId is null)
	and (awayTeam.StateId is null)
    and (teamId is null
		or (homeTeam.Id = teamId or awayTeam.Id = teamId))
order by
	(CASE WHEN homeTeam.Name like '4Fun%' THEN m.AwayTeamScore - m.HomeTeamScore ELSE m.HomeTeamScore - m.AwayTeamScore END) desc
limit 3;

END $ $

DELIMITER ;