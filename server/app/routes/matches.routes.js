module.exports = (app) => {

	const controller = require("../controllers/match.controller");
	var router = require("express").Router();

	router.get("/player/:id", controller.listByPlayer);
	router.post("/player/:id", controller.listByPlayer);
	router.post("", controller.list);
	router.get("/teams/:teamId/:opponentTeamId", controller.listMutualMatches);
	router.get("/stats/:teamId", controller.listBestWorst);
	router.get("/stats", controller.listBestWorst);

	app.use("/api/matches", router);
};
