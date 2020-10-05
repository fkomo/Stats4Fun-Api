const { query } = require("../models/db");

function getPlayerStats(row) {
	if (row == null) return null;
	return {
		playerId: row.PlayerId,
		name: row.Name,
		number: row.PlayerNumber,
		dateOfBirth: row.DateOfBirth,
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
	let playerStateId =
		req.body.playerStateId == null ? "null" : req.body.playerStateId;
	let args = `${seasonId}, ${teamId}, ${matchTypeId}, ${placeId}, ${playerPositionId}, ${competitionId}, ${playerStateId}`;
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
		dateOfBirth:
			row.DateOfBirth == null
				? null
				: new Date(row.DateOfBirth).toISOString().slice(0, 10),
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

exports.getMvp = (req, res) => {
	const teamId =
		req.params.teamId == null || req.params.teamId == 0
			? "null"
			: req.params.teamId;
	query(`call fun.GetMVP(${req.params.seasonId},${teamId})`)
		.then((queryResult) => {
			res.json({ season: req.params.seasonId, player: getPlayerStats(queryResult[0][0]) });
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.listMvps = (req, res) => {
	const teamId =
		req.params.teamId == null || req.params.teamId == 0
			? "null"
			: req.params.teamId;
	query("call fun.ListSeasons()")
		.then((qr1) => {
			var seasons = [];
			qr1[0].forEach(function (row) {
				seasons.push(row.Season);
			});

			var result = [];
			for (var i = 0; i < seasons.length; i++) {
				const season = seasons[i];
				query(`call fun.GetMVP(${season},${teamId})`)
					.then((qr2) => {
						result.push({
							season: season,
							player: getPlayerStats(
								qr2[0].length == 1 ? qr2[0][0] : null
							),
						});
						if (result.length == seasons.length) res.json(result);
					})
					.catch((err) => {
						res.send(err);
					});
			}
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.hattricks = (req, res) => {
	const teamId =
		req.params.teamId == null || req.params.teamId == 0
			? "null"
			: req.params.teamId;
	query(`call fun.ListPlayersWithMostHattricks(${teamId})`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({
					playerId: row.PlayerId,
					playerName: row.PlayerName,
					hattricks: row.HattrickCount,
				});
			});
			res.json(result);
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.goals = (req, res) => {
	const teamId =
		req.params.teamId == null || req.params.teamId == 0
			? "null"
			: req.params.teamId;
	query(`call fun.ListMostGoalsCount(${teamId})`)
		.then((qr1) => {
			var result = [];
			const resultCount = qr1[0].length;
			for (var i = 0; i < resultCount; i++) {
				query(
					`call fun.ListPlayersWithGoals(${qr1[0][i].Goals}, ${teamId})`
				)
					.then((qr2) => {
						let players = [];
						qr2[0].forEach(function (row) {
							players.push({
								playerId: row.PlayerId,
								playerName: row.PlayerName,
								matchId: row.MatchId,
							});
						});
						result.push({
							goals: qr2[0][0].Goals,
							players: players,
						});
						if (result.length == resultCount) {
							res.json(result);
						}
					})
					.catch((err) => {
						res.send(err);
					});
			}
		})
		.catch((err) => {
			res.send(err);
		});
};
