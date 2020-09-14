var mysql = require("mysql");
var dbConfig = require("../config/db.config.js");

var pool = mysql.createPool({
    connectionLimit: dbConfig.connectionLimit,
    host: dbConfig.host,
    user: dbConfig.user,
    password: dbConfig.password,
    database: dbConfig.database,
});

function query(sql) {
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