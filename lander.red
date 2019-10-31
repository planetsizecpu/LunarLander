Red [Needs: 'View
	Title:   "Lander"
	Author:  "@planetsizecpu"
	File:    "lander.red"
] 


recycle/off
system/view/auto-sync?:  yes

; Game data & defaults object
GameData: context [
	GameRate: 0:00:00.004 
	Gravity: 3
	Antigravity: 3
	HorizontalStep: 1
	DeadAltitude: 60
	TerrainColor: 178.178.178.0
	Curlevel: 1
	WindowHcenter: 400
	WindowHlimitL: 1
	WindowHlimitR: 778
	
	; Make moon object
	MoonImg: load %moon.png
	Moon: make face! [type: 'panel size: MoonImg/size offset: 0x0 pane: copy [] draw: copy [] 
					  image: copy MoonImg extra: [] focus: true]
	MoonFace: Moon
	MoonFaceHalfSizeX: (MoonFace/size/x / 2) * -1
			  
	
	; Make lander object
	Lander: object [
			name: "Lander"
			facename: "LanderFace" 
			face: copy []
			size: to-pair 20x20 
			offset: to-pair 400x10 
			direction: 6
			rate: 0:0:00.1
			walking: 0
			lastdir: 0
			inertia: 0.0
			altitude: 0
			lives: 4
			gravity: true
			display: true
			dead: false
			image: load %ship.png
			images: copy []			
			face: object! []
	]
]

CheckStatus: function [][
	Ret: false
		
	; Check for player dead
	if GameData/Lander/dead [Message "No more lives" Ret: true ]


	return Ret
]


; Gravity function for lander
LanderGravity: function [f [object!]] [
]

; Check keyboard for handling
CheckKeyboard: function [face key][
	switch key [
		left [GoLeft GameData/Moon]
		right [GoRight GameData/Moon]
		up [GoUp GameData/PlayerFace]
		down [GoDown GameData/PlayerFace]
		#" " [GoAction GameData/PlayerFace]
	]
]

; Left direction simulation
GoLeft: function [f [object!]][

	; if ship is at the window center move the scenary else move the ship
	either GameData/Lander/face/offset/x = GameData/WindowHcenter [
		either f/offset/x <= 0 [
			f/offset/x: f/offset/x + GameData/HorizontalStep
			info/text: copy to-string f/offset/x
		][
			GameData/Lander/face/offset/x: GameData/Lander/face/offset/x - GameData/HorizontalStep
		]
	][
		if GameData/Lander/face/offset/x > GameData/WindowHlimitL [
			GameData/Lander/face/offset/x: GameData/Lander/face/offset/x - GameData/HorizontalStep
		]
	]
]

; Right direction simulation
GoRight: function [f [object!]][

	; if ship is at the window center move the scenary else move the ship
	either GameData/Lander/face/offset/x = GameData/WindowHcenter [	
		either f/offset/x >= GameData/MoonFaceHalfSizeX [
			f/offset/x: f/offset/x - GameData/HorizontalStep
			info/text: copy to-string f/offset/x
		][
			GameData/Lander/face/offset/x: GameData/Lander/face/offset/x + GameData/HorizontalStep
		]
	][
		if GameData/Lander/face/offset/x < GameData/WindowHlimitR [
			GameData/Lander/face/offset/x: GameData/Lander/face/offset/x + GameData/HorizontalStep
		]
	]
]



; Set game screen layout
GameScr: layout [
	title "Moon Lander"
	size 800x750
	origin 0x0
	space 0x0
	
	; Info field is also used for event management!
	at 10x610 info: base 780x30 blue orange font [name: "Arial" size: 14 style: 'bold] focus 
	rate GameData/GameRate on-time [
		info/rate: none 
		if CheckStatus [alert "END OF GAME" quit] 
		info/rate: GameData/GameRate
	]
	below
]

	LanderFace: make face! [type: 'base size: GameData/Lander/size offset: GameData/Lander/offset image: copy GameData/Lander/image extra: GameData/Lander
							rate: GameData/Lander/rate actors: context [on-time: func [f e][LanderGravity f]]]
	GameData/Lander/face: LanderFace
	append GameScr/pane GameData/Moon
	append GameScr/pane LanderFace
	
view/options GameScr [actors: context [on-key: func [face event][CheckKeyboard face event/key]]]



