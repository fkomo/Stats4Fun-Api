const { authenticationRequired } = require("./auth");

module.exports = (app) => {

	const controller = require("../controllers/player.controller");
	var router = require("express").Router();

	router.get("/:id", controller.get);
	router.post("", authenticationRequired, controller.insert);
	router.put("/:id", authenticationRequired, controller.update);
	router.delete("/:id", authenticationRequired, controller.delete);
	router.get("/mvp/:seasonId/:teamId", controller.getMvp);

	app.use("/api/player", router);
};
