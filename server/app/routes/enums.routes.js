const { authenticationRequired } = require("./auth");

module.exports = (app) => {

	const controller = require("../controllers/enum.controller");
	var router = require("express").Router();

	router.get("/teams", controller.enumTeams);
	router.get("/places", controller.enumPlaces);
	router.get("/playerPositions", controller.enumPlayerPositions);
	router.get("/matchTypes", controller.enumMatchTypes);
	router.get("/matchResults", controller.enumMatchResults);
	router.get("/seasons", controller.enumSeasons);
	router.get("/seasons/player/:id", controller.listSeasonsByPlayer);
	router.get("/competitions", controller.enumCompetitions);
	router.get("/playernames", controller.enumPlayerNames);
	router.get("/states", controller.enumStates);

	router.post("/:type", authenticationRequired, controller.insert);
	router.put("/:type/:id", authenticationRequired, controller.update);

	app.use("/api/enums", router);
};
