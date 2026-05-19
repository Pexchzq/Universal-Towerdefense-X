return {
	rewards = {
		enabled = true,
		claims = {
			{ kind = "WelcomeRewards", day = 1 },
			{ kind = "ReturnRewards", day = 1 },
		},
	},

	equip = {
		unequipAllFirst = true,
		teamSlots = {
			"FastCart", -- slot 1
			"Gohan", -- slot 2
			"Sasuke", -- slot 3
			"", -- slot 4
			"", -- slot 5
			"", -- slot 6
		},
	},

	summon = {
		enabled = true,
		targets = {
			FastCart = 2,
			Bulma = 1,
		},
		amount = "TenSummon",
		banner = "Special",
		waitAfter = 3.5,
	},
}

