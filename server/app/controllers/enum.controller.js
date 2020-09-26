const { query } = require("../models/db");

function createEnumArray(rows) {
	let result = [];
	rows.forEach(function (row) {
		result.push({ id: row.Id, name: row.Name });
	});
	return result;
}

exports.enumTeams = (req, res) => {
	query("call fun.ListEnumTeams()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumPlaces = (req, res) => {
	query("call fun.ListEnumPlaces()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumPlayerPositions = (req, res) => {
	query("call fun.ListEnumPlayerPositions()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumMatchTypes = (req, res) => {
	query("call fun.ListEnumMatchTypes()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumMatchResults = (req, res) => {
	query("call fun.ListEnumMatchResults()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumCompetitions = (req, res) => {
	query("call fun.ListEnumCompetitions()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumPlayerNames = (req, res) => {
	query("call fun.ListEnumPlayers(0)")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumStates = (req, res) => {
	query("call fun.ListEnumStates()")
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.enumSeasons = (req, res) => {
	query("call fun.ListSeasons()")
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({
					id: row.Season,
					name: row.Season + "/" + (parseInt(row.Season) + 1),
				});
			});
			res.json(result);
		})
		.catch((err) => {
			res.send(err);
		});
};

exports.listSeasonsByPlayer = (req, res) => {
	query(`call fun.ListPlayerSeasons(${req.params.id})`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({
					id: row.Season,
					name: row.Season + "/" + (parseInt(row.Season) + 1),
				});
			});
			res.json(result);
		})
		.catch((err) => {
			res.send(err);
		});
};

const insertEnumTypes = [
	"team",
	"place",
	"competition",
	"matchtype",
	"playerposition",
	"state",
];

exports.insert = (req, res) => {
	let enumType = req.params.type;
	if (!insertEnumTypes.includes(enumType.toLowerCase()))
		return res.send("invalid enum type");

	let enumBody = req.body;
	if (enumBody == null || enumBody.name == null)
		return res.send("invalid input");

	query(`call fun.Insert${enumType}(\"${enumBody.name}\")`)
		.then((queryResult) => {
			res.json({ id: queryResult[0][0].Id, name: enumBody.name });
		})
		.catch((err) => {
			res.send(err);
		});
};

const modifyEnumTypes = [
	"team",
	"place",
	"competition",
	"matchtype",
	"playerposition",
	"state",
	"matchresult",
];

exports.update = (req, res) => {
	let enumType = req.params.type;
	if (!modifyEnumTypes.includes(enumType.toLowerCase()))
		return res.send("invalid enum type");

	let id = req.params.id;
	let enumBody = req.body;
	if (enumBody == null || enumBody.name == null || id == null)
		return res.send("invalid input");

	query(`call fun.Modify${enumType}(${id},\"${enumBody.name}\",null)`)
		.then((queryResult) => {
			res.json({ id: queryResult[0][0].Id, name: enumBody.name });
		})
		.catch((err) => {
			res.send(err);
		});
};
