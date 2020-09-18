module.exports = (app) => {

	const controller = require("../controllers/stats.controller");
	var router = require("express").Router();

	router.get("/player/:id", controller.listByPlayer);
	router.post("/player/:id", controller.listByPlayer);

	app.use("/api/stats", router);
};
