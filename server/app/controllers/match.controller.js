const { query } = require("../models/db");

function getMatch(row) {
	return {
		id: row.Id,
		dateTime: row.DateTime,
		matchTypeId: row.MatchTypeId,
		placeId: row.PlaceId,
		competitionId: row.CompetitionId,
		homeTeamId: row.HomeTeamId,
		awayTeamId: row.AwayTeamId,
		homeTeamScore: row.HomeTeamScore,
		awayTeamScore: row.AwayTeamScore,
		win: row.Win,
		loss: row.Loss,
		tie: row.Tie,
		players: [],
	};
}

function get4FunGoals(match) {
	if (match.win == 1)
		return Math.max(match.homeTeamScore, match.awayTeamScore);
	else if (match.loss == 1)
		return Math.min(match.homeTeamScore, match.awayTeamScore);
	else return match.homeTeamScore;
}

function getOponnentGoals(match) {
	if (match.win == 1)
		return Math.min(match.homeTeamScore, match.awayTeamScore);
	else if (match.loss == 1)
		return Math.max(match.homeTeamScore, match.awayTeamScore);
	else return match.homeTeamScore;
}

function getMatchesResult(matches, opponentTeamId) {
	return {
		opponentTeamId: opponentTeamId,
		gamesPlayed: matches.length,
		wins: matches.filter((m) => m.win == 1).length,
		losses: matches.filter((m) => m.loss == 1).length,
		ties: matches.filter((m) => m.tie == 1).length,
		goalsFor: matches.reduce(function (sum, m) {
			return sum + get4FunGoals(m);
		}, 0),
		goalsAgainst: matches.reduce(function (sum, m) {
			return sum + getOponnentGoals(m);
		}, 0),
		matches: matches,
	};
}

exports.listByPlayer = (req, res) => {
	let args = `${req.params.id}, ${
		req.body.season == null ? "null" : req.body.season
	}`;
	query(`call fun.ListMatchesByPlayerId(${args})`)
		.then((queryResult) => {
			let matches = [];
			queryResult[0].forEach(function (row) {
				matches.push(getMatch(row));
			});
			res.json(getMatchesResult(matches, null));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.list = (req, res) => {
	let seasonId = req.body.seasonId == null ? "null" : req.body.seasonId;
	let teamId = req.body.teamId == null ? "null" : req.body.teamId;
	let matchTypeId =
		req.body.matchTypeId == null ? "null" : req.body.matchTypeId;
	let competitionId =
		req.body.competitionId == null ? "null" : req.body.competitionId;
	let placeId = req.body.placeId == null ? "null" : req.body.placeId;
	let matchResultId =
		req.body.matchResultId == null ? "null" : req.body.matchResultId;

	let args = `${seasonId}, ${teamId}, ${matchTypeId}, ${competitionId}, ${placeId}, ${matchResultId}`;
	query(`call fun.ListMatches(${args})`)
		.then((queryResult) => {
			let matches = [];
			queryResult[0].forEach(function (row) {
				matches.push(getMatch(row));
			});
			res.json(getMatchesResult(matches, null));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.listMutualMatches = (req, res) => {
	query(
		`call fun.ListMutualMatches(${req.params.teamId}, ${req.params.opponentTeamId})`
	)
		.then((queryResult) => {
			let matches = [];
			queryResult[0].forEach(function (row) {
				matches.push(getMatch(row));
			});
			res.json(getMatchesResult(matches, req.params.opponentTeamId));
		})
		.catch((err) => {
			res.send(err);
		});
};

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

exports.get = (req, res) => {
	query(`call fun.GetMatch(${req.params.id})`)
		.then((queryResult) => {
			let match = getMatch(queryResult[0][0]);
			query(`call fun.ListMatchPlayerStats(${req.params.id})`)
				.then((queryResult2) => {
					queryResult2[0].forEach(function (row) {
						match.players.push(getPlayerStats(row));
					});
					res.json(match);
				})
				.catch((err) => {
					res.send(err);
				});
		})
		.catch((err) => {
			res.send(err);
		});
};

function insertPlayerStats(match, players, res) {
	if (players == null || players.length < 1) res.json(match);
	else {
		players.forEach((p) => {
			let args = `${p.playerId}, ${match.id}, ${p.goals}, ${p.assists}, ${p.posNegPoints}, ${p.yellowCards}, ${p.redCards}`;
			query(`call fun.InsertPlayerStats(${args})`)
				.then((queryResult) => {
					match.players.push(getPlayerStats(queryResult[0][0]));
					if (match.players.length == players.length) {
						res.json(match);
					}
				})
				.catch((err) => {
					res.send(err);
				});
		});
	}
}

exports.insert = (req, res) => {
	let m = req.body;

	if (m.id != null) return this.update(req, res);

	let args = `'${m.dateTime}', '${m.matchTypeId}', ${m.placeId}, ${m.competitionId}, ${m.homeTeamId}, ${m.awayTeamId}, ${m.homeTeamScore}, ${m.awayTeamScore}`;
	query(`call fun.InsertMatch(${args})`)
		.then((queryResult) => {
			insertPlayerStats(getMatch(queryResult[0][0]), m.players, res);
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.update = (req, res) => {
	let m = req.body;
	let args = `${m.id}, '${m.dateTime}', '${m.matchTypeId}', ${m.placeId}, ${m.competitionId}, ${m.homeTeamId}, ${m.awayTeamId}, ${m.homeTeamScore}, ${m.awayTeamScore}`;
	query(`call fun.ModifyMatch(${args})`)
		.then((queryResult) => {
			query(`call fun.DeletePlayerStats(${m.id})`)
				.then((queryResult2) => {
					insertPlayerStats(
						getMatch(queryResult[0][0]),
						m.players,
						res
					);
				})
				.catch((err) => {
					res.send(err);
				});
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.delete = (req, res) => {
	query(`call fun.DeleteMatch(${req.params.id})`)
		.then((queryResult) => {
			res.json({
				result: "ok",
			});
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.listBestWorst = (req, res) => {
	const teamId =
		req.params.teamId == null || req.params.teamId == 0
			? "null"
			: req.params.teamId;

	query(`call fun.ListMatchesWithMostGoalsScored(${teamId})`)
		.then((qr1) => {
			var mostGoalsScored = [];
			qr1[0].forEach(function (row) {
				mostGoalsScored.push(getMatch(row));
			});
			query(`call fun.ListMatchesWithMostGoalsTaken(${teamId})`)
				.then((qr2) => {
					var mostGoalsTaken = [];
					qr2[0].forEach(function (row) {
						mostGoalsTaken.push(getMatch(row));
					});
					query(`call fun.ListMatchesWithHighestScoreDiff(${teamId})`)
						.then((qr3) => {
							var bestScoreDiff = [];
							qr3[0].forEach(function (row) {
								bestScoreDiff.push(getMatch(row));
							});
							query(`call fun.ListMatchesWithLowestScoreDiff(${teamId})`)
								.then((qr4) => {
									var worstScoreDiff = [];
									qr4[0].forEach(function (row) {
										worstScoreDiff.push(getMatch(row));
									});
									res.json({
										mostGoalsScored: mostGoalsScored,
										mostGoalsTaken: mostGoalsTaken,
										bestScoreDiff: bestScoreDiff,
										worstScoreDiff: worstScoreDiff,
									});
								})
								.catch((err) => {
									res.send(err);
								});
						})
						.catch((err) => {
							res.send(err);
						});
				})
				.catch((err) => {
					res.send(err);
				});
		})
		.catch((err) => {
			res.send(err);
		});
};
