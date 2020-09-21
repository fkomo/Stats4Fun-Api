module.exports = (app) => {

	const controller = require("../controllers/match.controller");
	var router = require("express").Router();

	router.get("/player/:id", controller.listByPlayer);
	router.post("/player/:id", controller.listByPlayer);
	router.post("", controller.list);
	router.get("/teams/:teamId/:opponentTeamId", controller.listMutualMatches);

	app.use("/api/matches", router);
};
