module.exports = (app) => {

	const controller = require("../controllers/match.controller");
	var router = require("express").Router();

	router.get("/:id", controller.get);
	router.post("", controller.insert);
	router.put("/:id", controller.update);
	router.delete("/:id", controller.delete);

	app.use("/api/match", router);
};
