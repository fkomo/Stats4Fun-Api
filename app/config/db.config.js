module.exports = {
	host: "192.168.1.228",
	user: "dev-remote",
	password: "dev",
	db: "fun",
	dialect: "mysql",
	pool: {
		max: 5, 
		min: 0,
		acquire: 30000,
		idle: 10000,
	},
};