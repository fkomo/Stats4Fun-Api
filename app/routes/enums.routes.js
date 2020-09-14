module.exports = (app) => {
	const enums = require("../controllers/enums.controller.js");

	var router = require("express").Router();

	router.get("/teams", enums.enumTeams);
	router.get("/places", enums.enumPlaces);
	router.get("/playerPositions", enums.enumPlayerPositions);
	router.get("/matchTypes", enums.enumMatchTypes);
	router.get("/matchResults", enums.enumMatchResults);
	router.get("/seasons", enums.enumSeasons);
	router.get("/competitions", enums.enumCompetitions);
	router.get("/players", enums.enumPlayers);

	//router.get("/:id", enums.findOne);
	//router.post("/", tutorials.create);
	//router.put("/:id", tutorials.update);
	//router.delete("/:id", tutorials.delete);

	app.use("/api/enums", router);
};
