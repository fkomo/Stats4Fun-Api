var mysql = require("mysql");

var pool = mysql.createPool({
	host: process.env.DB_HOST,
	user: process.env.DB_USER,
	password: process.env.DB_PASSWORD,
	database: process.env.DB_DATABASE,
	connectionLimit: process.env.DB_CONNECTION_LIMIT,
});

function query(sql) {
	console.log(sql);
	return new Promise((resolve, reject) => {
		pool.getConnection(function (err, connection) {
			if (err) {
				return reject(err);
			}
			connection.query(sql, true, function (err, result) {
				connection.release();
				if (err) {
					return reject(err);
				}
				return resolve(result);
			});
		});
	});
}

module.exports = { query };