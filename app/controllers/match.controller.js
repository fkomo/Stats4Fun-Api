const { query } = require("../models/db");

exports.listByPlayer = (req, res) => {
	
	let args = `${ req.params.id }, ${ req.body.season == null ? 'null' : req.body.season }`;
	query(`call fun.ListMatchesByPlayerId(${ args })`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({ 
					id: row.Id, 
					dateTime: row.DateTime,
					matchTypeId: row.MatchTypeId, 
					placeId: row.PlaceId,
					competitionId: row.CompetitionId,
					homeTeamId: row.HomeTeamId,
					awayTeamId: row.AwayTeamId,
					homeTeamScore: row.HomeTeamScore,
					awayTeamScore: row.AwayTeamScore,
					players: [],
				});
			});
			res.json(result);
		})		.catch((err) => {
			res.send(err);
		});
};
