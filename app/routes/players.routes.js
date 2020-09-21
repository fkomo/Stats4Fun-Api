module.exports = (app) => {

	const controller = require("../controllers/player.controller");
	var router = require("express").Router();

	router.post("/stats", controller.stats);
	router.get("/stats/match/:id", controller.statsByMatch);

	app.use("/api/players", router);
};
