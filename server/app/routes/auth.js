const OktaJwtVerifier = require("@okta/jwt-verifier");
const oktaJwtVerifier = new OktaJwtVerifier({
	issuer: `https://${process.env.OKTA_DOMAIN}/oauth2/default`,
});

function authenticationRequired(req, res, next) {
	const authHeader = req.headers.authorization || "";
	const match = authHeader.match(/Bearer (.+)/);

	if (!match) {
		res.status(401);
		return next("Unauthorized");
	}

	const accessToken = match[1];

	return oktaJwtVerifier
		.verifyAccessToken(accessToken, process.env.OKTA_AUDIENCE)
		.then((jwt) => {
			req.jwt = null;
			for (let i = 0; i < jwt.claims.groups.length; i++) {
				if (jwt.claims.groups[i] == "4fun admins") {
					req.jwt = jwt;
					break;
				}
			}
			if (req.jwt != null) next();
			else res.status(401);
		})
		.catch((err) => {
			res.status(401).send(err.message);
		});
}

module.exports = { authenticationRequired };
