module.exports = (app) => {

	const controller = require("../controllers/stats.controller");
	var router = require("express").Router();

	router.get("/player/:id", controller.listByPlayer);
	router.post("/player/:id", controller.listByPlayer);
	router.get("/team", controller.listTeam);
	router.get("/team/:teamId", controller.listTeam);

	app.use("/api/stats", router);
};
