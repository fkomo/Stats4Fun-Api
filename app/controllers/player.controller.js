const { query } = require("../models/db");

function getPlayerStats(row) {
	return {
		playerId: row.PlayerId,
		number: row.PlayerNumber,
		name: row.Name,
		playerPositionId: row.PlayerPositionId,
		teamId: row.TeamId,
		retired: row.PlayerStateId == "2",

		gamesPlayed: row.GamesPlayed,
		goals: row.Goals,
		assists: row.Assists,
		posNegPoints: row.PosNegPoints,
		points: row.Points,
		yellowCards: row.YellowCards,
		redCards: row.RedCards,

		playerStatsId: row.PlayerStatsId,
		matchId: row.MatchId,
		wins: row.WinCount,
		losses: row.LossCount,
		ties: row.TieCount,
	};
}

exports.stats = (req, res) => {
	let seasonId = req.body.seasonId == null ? "null" : req.body.seasonId;
	let teamId = req.body.teamId == null ? "null" : req.body.teamId;
	let matchTypeId =
		req.body.matchTypeId == null ? "null" : req.body.matchTypeId;
	let placeId = req.body.placeId == null ? "null" : req.body.placeId;
	let playerPositionId =
		req.body.playerPositionId == null ? "null" : req.body.playerPositionId;
	let competitionId =
		req.body.competitionId == null ? "null" : req.body.competitionId;
	let playerId = req.body.playerId == null ? "null" : req.body.playerId;
	let args = `${seasonId}, ${teamId}, ${matchTypeId}, ${placeId}, ${playerPositionId}, ${competitionId}, ${playerId}`;
	query(`call fun.ListPlayerStats(${args})`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push(getPlayerStats(row));
			});
			res.json(result);
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.statsByMatch = (req, res) => {
	query(`call fun.ListMatchPlayerStats(${req.params.id})`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push(getPlayerStats(row));
			});
			res.json(result);
		})
		.catch((err) => {
			res.send(err);
		});
};

function getPlayer(row) {
	return {
		playerId: row.Id,
		name: row.Name,
		number: row.Number,
		dateOfBirth: row.DateOfBirth == null ? null : new Date(row.DateOfBirth).toISOString().slice(0, 10),
		playerPositionId: row.PlayerPositionId,
		teamId: row.TeamId,
		retired: row.StateId == "2",
	};
}

exports.get = (req, res) => {
	query(`call fun.GetPlayer(${req.params.id})`)
		.then((queryResult) => {
			res.json(getPlayer(queryResult[0][0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.insert = (req, res) => {
	let p = req.body;
	let args = `'${p.dateOfBirth}', '${p.name}', ${p.number}, ${p.playerPositionId}, ${p.teamId}`;
	query(`call fun.InsertPlayer(${args})`)
		.then((queryResult) => {
			res.json(getPlayer(queryResult[0][0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.update = (req, res) => {
	let p = req.body;
	let stateId = p.retired == true ? 2 : null;
	let args = `${p.id}, '${p.dateOfBirth}', '${p.name}', ${p.number}, ${p.playerPositionId}, ${p.teamId}, ${stateId}`;
	query(`call fun.ModifyPlayer(${args})`)
		.then((queryResult) => {
			res.json(getPlayer(queryResult[0][0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.delete = (req, res) => {
	query(`call fun.DeletePlayer(${req.params.id})`)
		.then((queryResult) => {
			res.json({
				result: "ok",
			});
		})
		.catch((err) => {
			res.send(err);
		});
};
