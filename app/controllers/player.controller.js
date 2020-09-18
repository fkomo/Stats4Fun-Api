const { query } = require("../models/db");

exports.stats = (req, res) => {
	
	let seasonId = req.body.seasonId == null ? 'null' : req.body.seasonId;
	let teamId = req.body.teamId == null ? 'null' : req.body.teamId;
	let matchTypeId = req.body.matchTypeId == null ? 'null' : req.body.matchTypeId;
	let placeId = req.body.placeId == null ? 'null' : req.body.placeId;
	let playerPositionId = req.body.playerPositionId == null ? 'null' : req.body.playerPositionId;
	let competitionId = req.body.competitionId == null ? 'null' : req.body.competitionId;
	let playerId = req.body.playerId == null ? 'null' : req.body.playerId;

	let args = `${ seasonId }, ${ teamId }, ${ matchTypeId }, ${ placeId }, ${ playerPositionId }, ${ competitionId }, ${ playerId }`;
	
	query(`call fun.ListPlayerStats(${ args })`)
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({ 
					id: row.PlayerId, 
					number: row.PlayerNumber,
					name: row.Name, 
					gamesPlayed: row.GamesPlayed,
					goals: row.Goals,
					assists: row.Assists,
					posNegPoints: row.PosNegPoints,
					points: row.Points,
					yellowCards: row.YellowCards,
					redCards: row.RedCards,
					playerPositionId: row.PlayerPositionId,
					teamId: row.TeamId,
					retired: row.PlayerStateId == '2',
					wins: row.WinCount,
					losses: row.LossCount,
					ties: row.TieCount,
				});
			});
			res.json(result);
		});
};

exports.get = (req, res) => {
		
	query(`call fun.GetPlayer(${ req.params.id })`)
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			var row = queryResult[0][0];
			res.json({ 
				id: row.Id, 
				name: row.Name, 
				number: row.Number,
				dateOfBirth: row.DateOfBirth,
				playerPositionId: row.PlayerPositionId,
				teamId: row.TeamId,
				retired: row.StateId == '2',
			});
		});
};
