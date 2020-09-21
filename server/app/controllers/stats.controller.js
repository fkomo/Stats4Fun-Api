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
