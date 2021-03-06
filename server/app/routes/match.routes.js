const { authenticationRequired } = require("./auth");

module.exports = (app) => {

	const controller = require("../controllers/match.controller");
	var router = require("express").Router();

	router.get("/:id", controller.get);
	router.post("", authenticationRequired, controller.insert);
	router.put("/:id", authenticationRequired, controller.update);
	router.delete("/:id", authenticationRequired, controller.delete);

	app.use("/api/match", router);
};
