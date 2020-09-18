const { query } = require("../models/db");

exports.listByPlayer = (req, res) => {
	
	let args = `${ req.params.id }, ${ req.body.season == null ? 'null' : req.body.season }`;
	query(`call fun.ListPlayerStatsByPlayerId(${ args })`)
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({ 
					id: row.Id, 
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
		});
};