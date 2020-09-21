const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const app = express();

var corsOptions = {
	origin: "http://localhost:8042",
};

app.use(cors(corsOptions));

// parse requests of content-type - application/json
app.use(bodyParser.json());

// parse requests of content-type - application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }));

// simple route
app.get("/", (req, res) => {
	res.json({ "api-list": [ 
		{ url: "/api/enums/teams", description: "" },
		{ url: "/api/enums/places", description: "" },
		{ url: "/api/enums/playerPositions", description: "" },
		{ url: "/api/enums/matchTypes", description: "" },
		{ url: "/api/enums/matchResults", description: "" },
		{ url: "/api/enums/seasons", description: "" },
		{ url: "/api/enums/competitions", description: "" },
		{ url: "/api/enums/playerNames", description: "" },
		{ url: "/api/enums/:enumName", description: "" },
		{ url: "/api/enums/:enumName/:id", description: "" },

	]});
});

require("./server/app/routes/enums.routes")(app);
require("./server/app/routes/matches.routes")(app);
require("./server/app/routes/match.routes")(app);
require("./server/app/routes/players.routes")(app);
require("./server/app/routes/player.routes")(app);
require("./server/app/routes/stats.routes")(app);

// set port, listen for requests
const PORT = process.env.PORT || 8042;
app.listen(PORT, () => {
	console.log(`Server is running on port ${PORT}.`);
});
