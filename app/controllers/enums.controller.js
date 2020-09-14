const { query } = require('../models/db');

exports.enumTeams = (req, res) => {
	query(`call fun.ListEnumTeams()`)
		.then((queryResult) => {
			let result = [];
			queryResult[0].forEach(function (row) {
				result.push({ id: row.Id, name: row.Name });
			});
			res.json(result);
		});
};

// exports.enumPlaces = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListEnumPlaces()`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Id, name: row.Name });
// 			});
// 			res.json(result);
// 		}
// 	});
// };

// exports.enumPlayerPositions = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListEnumPlayerPositions()`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Id, name: row.Name });
// 			});
// 			res.json(result);
// 		}
// 	});
// };

// exports.enumMatchTypes = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListEnumMatchTypes()`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Id, name: row.Name });
// 			});
// 			res.json(result);
// 		}
// 	});
// };

// exports.enumMatchResults = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListEnumMatchResults()`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Id, name: row.Name });
// 			});
// 			res.json(result);
// 		}
// 	});
// };

// exports.enumCompetitions = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListEnumCompetitions()`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Id, name: row.Name });
// 			});
// 			res.json(result);
// 		}
// 	});
// };

// exports.enumSeasons = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListSeasons()`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Season, name: row.Season + "/" + (parseInt(row.Season) + 1) });
// 			});
// 			res.json(result);
// 		}
// 	});
// };

// exports.enumPlayers = (req, res) => {
// 	var connection = mysql.createConnection({
// 		host: dbConfig.host,
// 		user: dbConfig.user,
// 		password: dbConfig.password,
// 	});

// 	var command = `call fun.ListEnumPlayers(0)`;
// 	connection.query(command, true, (error, results, fields) => {
// 		if (error) res.send(error.message);
// 		else {
// 			var result = [];
// 			results[0].forEach(function (row) {
// 				result.push({ id: row.Id, name: row.Name });
// 			});
// 			res.json(result);
// 		}
// 	});
// };
