const { query } = require("../models/db");

exports.listByPlayer = (req, res) => {
	let args = `${req.params.id}, ${
		req.body.season == null ? "null" : req.body.season
	}`;
	query(`call fun.ListPlayerStatsByPlayerId(${args})`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({
					playerStatsId: row.PlayerStatsId,
					playerId: row.PlayerId,
					matchId: row.MatchId,
					goals: row.Goals,
					assists: row.Assists,
					points: row.Goals + row.Assists,
					posNegPoints: row.PosNegPoints,
					yellowCards: row.YellowCards,
					redCards: row.RedCards,
				});
			});
			res.json(result);
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.listTeam = (req, res) => {
	const teamId =
		req.params.teamId == null || req.params.teamId == 0
			? "null"
			: req.params.teamId;
	query(`call fun.ListTeamStatsInSeasons(${teamId})`)
		.then((queryResult) => {
			query(`call fun.ListCardsInSeasons(${teamId})`)
				.then((queryResult2) => {
					let result = [];
					for (var i = 0; i < queryResult[0].length; i++) {
						const seasonId = queryResult[0][i].SeasonId;
						const cards = queryResult2[0].find(row => row.SeasonId == seasonId);
						console.log(cards);
						result.push({
							seasonId: seasonId,
							gamesPlayed: queryResult[0][i].GamesPlayed,
							wins: queryResult[0][i].Wins,
							losses: queryResult[0][i].Losses,
							ties: queryResult[0][i].Ties,
							goalsFor: queryResult[0][i].GoalsFor,
							goalsAgainst: queryResult[0][i].GoalsAgainst,
							yellowCards: cards == null ? 0 : cards.YellowCards,
							redCards: cards == null ? 0 : cards.RedCards,
						});
					}
					res.json(result);
				})
				.catch((err) => {
					res.send(err);
				});
		})
		.catch((err) => {
			res.send(err);
		});
};
