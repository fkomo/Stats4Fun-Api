module.exports = (app) => {

	const controller = require("../controllers/player.controller");
	var router = require("express").Router();

	router.post("/stats", controller.stats);
	router.get("/stats/match/:id", controller.statsByMatch);

	router.get("/hattricks/:teamId", controller.hattricks);
	router.get("/hattricks", controller.hattricks);
	router.get("/goals", controller.goals);
	router.get("/goals/:teamId", controller.goals);
	router.get("/mvp/:teamId", controller.listMvps);

	app.use("/api/players", router);
};
