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
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumPlaces = (req, res) => {
	query("call fun.ListEnumPlaces()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumPlayerPositions = (req, res) => {
	query("call fun.ListEnumPlayerPositions()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumMatchTypes = (req, res) => {
	query("call fun.ListEnumMatchTypes()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumMatchResults = (req, res) => {
	query("call fun.ListEnumMatchResults()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumCompetitions = (req, res) => {
	query("call fun.ListEnumCompetitions()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumPlayers = (req, res) => {
	query("call fun.ListEnumPlayers(0)")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumStates = (req, res) => {
	query("call fun.ListEnumStates()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			res.json(createEnumArray(queryResult[0]));
		});
};

exports.enumSeasons = (req, res) => {
	query("call fun.ListSeasons()")
		.catch((err) => {
			res.send(err);
		})
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({
					id: row.Season,
					name: row.Season + "/" + (parseInt(row.Season) + 1),
				});
			});
			res.json(result);
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
	"matchresult"
];

exports.update = (req, res) => {
	let enumType = req.params.type;
	if (!modifyEnumTypes.includes(enumType.toLowerCase()))
		return res.send("invalid enum type");

	let id = req.params.id;
	let enumBody = req.body;
	query(`call fun.Modify${enumType}(${id},\"${enumBody.name}\",null)`)
		.then((queryResult) => {
			res.json({ id: queryResult[0][0].Id, name: enumBody.name });
		})
		.catch((err) => {
			res.send(err);
		});
};
