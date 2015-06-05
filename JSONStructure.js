// Pour la connexion de l'utilisateur
var userLoginClient = {
	login: "<string>",
	password: "<string>"
};
var userLoginServerResponse = {
	token: "<string>",
	pseudo: "<string>",
	energy: "<int>",
	roundEnd: "<timestamp>",
	camp: "<enum>{HUMAN/ALIEN}",
	team: {
		teamID: "<int>",
		tag: "<string>",
		slogan: "<string>",
		players: [
			{
				playerID: "<int>",
				pseudo: "<string>",
				online: "<boolean>",
				energy: "<int>"
			}
		]
	}
};

// Capture de point
var clientCapture = {
	token: "<string>",
	support: "<enum>{NFC, QR}",
	data: "<string>",
	location: "<string?>"
};

// Objets génériques pour la mise a jour de l'etat du jeu et du joueur
var gameUpdateFeed = {
	roundEnd: "<timestamp>",
	points: [
		{
			pointID: "<int>",
			state: "<enum>{ALIEN, HUMAN, NEUTRAL}",
			energy: "<int>",
			effects: [
				{
					effect: "<id>",
					started: "<timestamp>",
					duration: "<int>"
				}
			],
			backlog: [
				{
					item: "<string>",
					data: "<string>",
					time: "<timestamp>"
				}
			]
		}
	]
};

var playerUpdateFeed = {
	pseudo: "<string>",
	energy: "<int>",
	camp: "<enum>{HUMAN/ALIEN}",
	team: {
		teamID: "<int>",
		tag: "<string>",
		slogan: "<string>",
		players: [
			{
				playerID: "<int>",
				pseudo: "<string>",
				online: "<boolean>",
				energy: "<int>"
			}
		]
	}
};
