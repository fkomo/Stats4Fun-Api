require("dotenv").config();

const { authenticationRequired } = require("./server/app/routes/auth");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();
app.use(
	cors({
		origin: process.env.CORS_CLIENT_ORIGIN,
	})
);

// parse requests of content-type - application/json
app.use(bodyParser.json());

// parse requests of content-type - application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }));

// api index
app.get("/", (req, res) => {
	res.json({
		"api-list": [
			{ url: "/api/enums/teams", type: "get", description: "" },
			{ url: "/api/enums/places", type: "get", description: "" },
			{ url: "/api/enums/playerPositions", type: "get", description: "" },
			{ url: "/api/enums/matchTypes", type: "get", description: "" },
			{ url: "/api/enums/matchResults", type: "get", description: "" },
			{ url: "/api/enums/seasons", type: "get", description: "" },
			{ url: "/api/enums/competitions", type: "get", description: "" },
			{ url: "/api/enums/playerNames", type: "get", description: "" },
			{ url: "/api/enums/states", type: "get", description: "" },
			{ url: "/api/enums/:enumName", type: "post", description: "" },
			{ url: "/api/enums/:enumName/:id", type: "put", description: "" },

			{ url: "/api/match/:id", type: "get", description: "" },
			{ url: "/api/match", type: "post", description: "" },
			{ url: "/api/match/:id", type: "put", description: "" },
			{ url: "/api/match/:id", type: "delete", description: "" },

			{ url: "/api/matches/player/:id", type: "get", description: "" },
			{ url: "/api/matches/player/:id", type: "post", description: "" },
			{ url: "/api/matches", type: "post", description: "" },
			{
				url: "/api/matches/teams/:teamId/:opponentTeamId",
				type: "get",
				description: "",
			},

			{ url: "/api/player/:id", type: "get", description: "" },
			{ url: "/api/player", type: "post", description: "" },
			{ url: "/api/player/:id", type: "put", description: "" },
			{ url: "/api/player/:id", type: "delete", description: "" },

			{ url: "/api/players/stats", type: "post", description: "" },
			{
				url: "/api/players/stats/match/:id",
				type: "get",
				description: "",
			},

			{ url: "/api/stats/player/:id", type: "get", description: "" },
			{ url: "/api/stats/player/:id", type: "post", description: "" },
		],
	});
});

// api routes
require("./server/app/routes/enums.routes")(app);
require("./server/app/routes/matches.routes")(app);
require("./server/app/routes/match.routes")(app);
require("./server/app/routes/players.routes")(app);
require("./server/app/routes/player.routes")(app);
require("./server/app/routes/stats.routes")(app);

app.get("/api/auth", authenticationRequired, (req, res) => {
	res.json(req.jwt);
});

// const https = require("https");
// const fs = require("fs");
// https
// 	.createServer(
// 		{
// 			key: fs.readFileSync(process.env.SSL_KEY_PEM),
// 			cert: fs.readFileSync(process.env.SSL_CERT_PEM),
// 			passphrase: process.env.SSL_PASSPHRASE,
// 		},
// 		app
// 	)
// 	.listen(process.env.PORT, process.env.HOST, () => {
// 		console.log(
// 			`stats4fun-api is running on https://${process.env.HOST}:${process.env.PORT}`
// 		);
// 	});

app.listen(process.env.PORT, () => {
	console.log(`stats4fun-api is running on http://${process.env.HOST}:${process.env.PORT}`);
});
