module.exports = (app) => {

	const controller = require("../controllers/player.controller");
	var router = require("express").Router();

	router.post("/stats", controller.stats);

	app.use("/api/players", router);
};
