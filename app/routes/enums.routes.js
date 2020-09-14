module.exports = (app) => {

	const enums = require("../controllers/enums.controller");
	var router = require("express").Router();

	router.get("/teams", enums.enumTeams);
	router.get("/places", enums.enumPlaces);
	router.get("/playerPositions", enums.enumPlayerPositions);
	router.get("/matchTypes", enums.enumMatchTypes);
	router.get("/matchResults", enums.enumMatchResults);
	router.get("/seasons", enums.enumSeasons);
	router.get("/competitions", enums.enumCompetitions);
	router.get("/players", enums.enumPlayers);
	router.get("/states", enums.enumStates);
	router.post("/:type", enums.insert);
	router.put("/:type/:id", enums.update);

	app.use("/api/enums", router);
};
