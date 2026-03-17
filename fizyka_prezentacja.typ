// ──────────────────────────────────────────────────────────
//  PI-CVAE · Fizyka problemu  —  EUCYS 2026
// ──────────────────────────────────────────────────────────

#set page(
	width: 297mm,
	height: 167mm,
	margin: (x: 18mm, top: 14mm, bottom: 20mm),
	fill: rgb("#f7f8fc"),
	background: place(top + left)[
		#rect(width: 100%, height: 4.5pt, fill: gradient.linear(rgb("#5b7fa6"), rgb("#6bafcc"), rgb("#7bbf96"), rgb("#d4a46a"), angle: 0deg))
	],
	footer: context [
		#line(length: 100%, stroke: (paint: rgb("#e2e4ec"), thickness: 0.3pt))
		#v(4pt)
		#grid(
			columns: (1fr, auto, 1fr),
			gutter: 0pt,
			text(size: 7.5pt, fill: rgb("#9aa0b0"), tracking: 0.6pt)[PI-CVAE  ·  Fizyka problemu],
			align(center)[
				#box(
					inset: (x: 8pt, y: 2.5pt),
					radius: 999pt,
					fill: rgb("#5b7fa6"),
				)[#text(size: 7pt, fill: white, weight: "bold")[#counter(page).display()]]
			],
			align(right)[#text(size: 7.5pt, fill: rgb("#9aa0b0"), tracking: 0.6pt)[EUCYS 2026]],
		)
	],
)

#set text(font: "Palatino Linotype", fill: rgb("#2c3040"), size: 16pt)
#set par(justify: true, leading: 1.1em)

#show math.equation: set text(font: "Cambria Math", fill: rgb("#4a6a8a"))
#show math.equation.where(block: true): set text(size: 16pt)

#let navy   = rgb("#5b7fa6")
#let teal   = rgb("#6bafcc")
#let amber  = rgb("#d4a46a")
#let sage   = rgb("#7bbf96")
#let ink    = rgb("#2c3040")
#let muted  = rgb("#6b7488")
#let subtle = rgb("#9aa0b0")
#let border = rgb("#e0e2ea")
#let soft   = white

#let slide(body) = page(body)

#let slide-title(title, subtitle: none) = [
	#block(width: 100%)[
		#text(size: 8pt, tracking: 3.5pt, fill: subtle, weight: "bold")[PI — CVAE]
		#v(6pt)
		#text(size: 27pt, weight: "bold", fill: navy)[#title]
		#v(9pt)
		#rect(width: 65mm, height: 2.5pt, fill: gradient.linear(navy, teal, sage, amber), radius: 999pt)
		#if subtitle != none [
			#v(7pt)
			#text(size: 10.5pt, fill: muted, style: "italic")[#subtitle]
		]
	]
	#v(14pt)
]

#let card(title, fill-color: teal, body) = block(
	width: 100%,
	radius: 10pt,
	clip: true,
	breakable: false,
	fill: soft,
	stroke: (paint: border, thickness: 0.4pt),
	[
		#block(width: 100%, height: 3.5pt, fill: gradient.linear(fill-color, fill-color.lighten(25%)))
		#pad(left: 16pt, right: 15pt, top: 13pt, bottom: 14pt)[
			#text(size: 11.8pt, weight: "bold", fill: fill-color)[#title]
			#v(6pt)
			#line(length: 100%, stroke: (paint: rgb("#e8eaf0"), thickness: 0.4pt))
			#v(8pt)
			#block[
				#set text(size: 11pt)
				#set par(leading: 1.1em, justify: true)
				#body
			]
		]
	],
)

#let plain(body) = block(
	width: 100%,
	inset: (left: 14pt, right: 13pt, top: 9pt, bottom: 10pt),
	radius: 8pt,
	breakable: false,
	fill: rgb("#eef6f2"),
	stroke: (left: (paint: sage, thickness: 3pt), rest: (paint: sage.lighten(70%), thickness: 0.35pt)),
	[
		#text(size: 9.5pt, weight: "bold", fill: sage, tracking: 0.3pt)[Innymi słowy: ]
		#text(size: 10.5pt, fill: ink)[#body]
	],
)

#let insight(body) = block(
	width: 100%,
	inset: (left: 15pt, right: 13pt, top: 10pt, bottom: 10pt),
	radius: 8pt,
	breakable: false,
	fill: rgb("#fdf5ea"),
	stroke: (
		left: (paint: amber, thickness: 3pt),
		rest: (paint: amber.lighten(65%), thickness: 0.35pt),
	),
	[
		#set par(justify: true)
		#text(size: 9.5pt, fill: amber)[◆] #h(4pt)
		#text(size: 10.8pt, style: "italic", fill: rgb("#8a6530"))[#body]
	],
)

#let stage(title, subtitle, fill-color) = block(
	width: 100%,
	radius: 9pt,
	clip: true,
	breakable: false,
	stroke: (paint: border, thickness: 0.35pt),
	fill: soft,
	[
		#block(width: 100%, height: 3.5pt, fill: gradient.linear(fill-color, fill-color.lighten(30%)))
		#pad(x: 13pt, bottom: 11pt, top: 9pt)[
			#block[
				#set text(size: 13pt, weight: "bold", fill: ink)
				#title
			]
			#v(5pt)
			#block[
				#set text(size: 9.5pt, fill: muted, style: "italic")
				#set par(leading: 1.0em, justify: false)
				#subtitle
			]
		]
	],
)

#let compact-stage(title, subtitle, fill-color) = block(
	width: 100%,
	radius: 8pt,
	clip: true,
	breakable: false,
	stroke: (paint: border, thickness: 0.4pt),
	fill: soft,
	[
		#block(width: 100%, height: 2.5pt, fill: gradient.linear(fill-color, fill-color.lighten(30%)))
		#pad(x: 8pt, bottom: 6pt, top: 5pt)[
			#block[
				#set text(size: 11pt, weight: "bold", fill: ink)
				#title
			]
			#v(2pt)
			#block[
				#set text(size: 8.5pt, fill: muted)
				#set par(leading: 0.95em, justify: false)
				#subtitle
			]
		]
	],
)

#let micro-stage(title, subtitle, fill-color) = block(
	width: 100%,
	radius: 8pt,
	clip: true,
	breakable: false,
	stroke: (paint: border, thickness: 0.4pt),
	fill: soft,
	[
		#block(width: 100%, height: 2.5pt, fill: gradient.linear(fill-color, fill-color.lighten(30%)))
		#pad(x: 7pt, bottom: 5pt, top: 4pt)[
			#block[
				#set text(size: 10.2pt, weight: "bold", fill: ink)
				#title
			]
			#v(1pt)
			#block(width: 100%)[
				#set text(size: 8pt, fill: muted)
				#set par(leading: 0.9em, justify: false)
				#subtitle
			]
		]
	],
)

#let tag(text-body, fill-color: sage) = rect(
	inset: (x: 11pt, y: 4.5pt),
	radius: 999pt,
	fill: fill-color.lighten(88%),
	stroke: (paint: fill-color.lighten(30%), thickness: 0.8pt),
	[#text(size: 9.5pt, weight: "bold", tracking: 0.4pt, fill: fill-color)[#text-body]],
)

#let icon-tag(symbol, fill-color) = rect(
	inset: (x: 7pt, y: 3pt),
	radius: 999pt,
	fill: fill-color.lighten(88%),
	stroke: (paint: fill-color.lighten(30%), thickness: 0.8pt),
	[#text(size: 9pt, weight: "bold", fill: fill-color)[#symbol]],
)

#let arrow() = align(center + horizon)[
	#box(inset: (x: 3pt))[
		#text(size: 17pt, fill: rgb("#c0c4d0"), baseline: -0.5pt)[⟶]
	]
]

#let stage-box(width, title, subtitle, fill-color) = align(center)[
	#block(width: width)[
		#stage(title, subtitle, fill-color)
	]
]

#let formula(body) = align(center)[
	#rect(
		inset: (x: 16pt, y: 8pt),
		radius: 8pt,
		fill: gradient.linear(rgb("#eff3fa"), rgb("#f6f8fc"), angle: 90deg),
		stroke: (paint: rgb("#d4dbed"), thickness: 0.5pt),
		[
			#set text(size: 12.5pt)
			#body
		],
	)
]


// ══════════════════════════════════════════════════════════
// SLAJD 0 — OKŁADKA
// ══════════════════════════════════════════════════════════

#page(footer: none, fill: rgb("#3d5a7a"), margin: 0mm, background: none)[
	#place(center + horizon)[
		#rotate(
			-12deg,
			origin: center,
			rect(
				width: 350mm,
				height: 0.4pt,
				fill: rgb("#4a6a8d"),
			),
		)
	]
	#place(center + horizon, dy: 25mm)[
		#rotate(
			-12deg,
			origin: center,
			rect(
				width: 300mm,
				height: 0.3pt,
				fill: rgb("#456285"),
			),
		)
	]

	#place(bottom + left)[
		#rect(width: 100%, height: 5pt, fill: gradient.linear(teal, sage, amber, angle: 0deg))
	]

	#align(center + horizon)[
		#block(inset: (x: 40mm, y: 25mm))[
			#text(size: 9pt, tracking: 6pt, fill: rgb("#8aaec5"), weight: "bold")[EUCYS 2026]
			#v(20pt)
			#line(length: 55mm, stroke: (paint: rgb("#5a7ea0"), thickness: 0.5pt))
			#v(26pt)
			#text(size: 50pt, weight: "bold", fill: white, tracking: 2pt)[FIZYKA SOL]
			#v(12pt)
			#text(size: 15.5pt, fill: rgb("#bdd6ec"), style: "italic")[Jakie zjawiska opisuje PI-CVAE i dlaczego są ważne?]
			#v(7pt)
			#text(size: 12pt, fill: rgb("#95b8d2"))[od plazmy w tokamaku do ograniczeń fizycznych w modelu]
			#v(32pt)
			#stack(
				dir: ltr,
				spacing: 0pt,
				rect(width: 36mm, height: 2.5pt, fill: rgb("#bdd6ec"), radius: (left: 999pt, right: 0pt)),
				rect(width: 22mm, height: 2.5pt, fill: teal),
				rect(width: 10mm, height: 2.5pt, fill: sage),
				rect(width: 14mm, height: 2.5pt, fill: amber, radius: (left: 0pt, right: 999pt)),
			)
			#v(34pt)
			#grid(
				columns: 3,
				column-gutter: 12pt,
				rect(inset: (x: 13pt, y: 6pt), radius: 999pt, fill: rgb("#4a6a8d"), stroke: (paint: rgb("#5e80a5"), thickness: 0.6pt))[
					#text(size: 8.8pt, fill: rgb("#bdd6ec"), weight: "bold", tracking: 0.3pt)[Plazma i transport]
				],
				rect(inset: (x: 13pt, y: 6pt), radius: 999pt, fill: rgb("#4a6a8d"), stroke: (paint: rgb("#5e80a5"), thickness: 0.6pt))[
					#text(size: 8.8pt, fill: rgb("#bdd6ec"), weight: "bold", tracking: 0.3pt)[Warstwa SOL]
				],
				rect(inset: (x: 13pt, y: 6pt), radius: 999pt, fill: rgb("#4a6a8d"), stroke: (paint: rgb("#5e80a5"), thickness: 0.6pt))[
					#text(size: 8.8pt, fill: rgb("#bdd6ec"), weight: "bold", tracking: 0.3pt)[Ograniczenia fizyczne]
				],
			)
			#v(38pt)
			#text(size: 9.5pt, fill: rgb("#7a9eb8"), tracking: 2pt)[FIZYKA PROBLEMU — PRZEGLĄD]
		]
	]
]

#counter(page).update(1)

// ══════════════════════════════════════════════════════════
// SLAJD 1 — CZYM JEST PLAZMA?
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Czym jest plazma?",
	subtitle: "Plazma to zjonizowany gaz: elektrony i jony poruszają się swobodnie i reagują na pola elektromagnetyczne.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 14pt,
		stage-box(63mm, "Gaz", [atomy są elektrycznie obojętne i zderzają się głównie mechanicznie], amber),
		[#arrow()],
		stage-box(63mm, "Ogrzewanie", [przy bardzo wysokiej temperaturze elektrony odrywają się od atomów], teal),
		[#arrow()],
		stage-box(63mm, "Plazma", [powstaje mieszanina jonów i elektronów sterowana także polem magnetycznym], sage),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Dlaczego plazma jest wyjątkowa?", fill-color: teal)[
		W zwykłym gazie cząsteczki zderzają się i poruszają losowo. W plazmie cząstki są #text(weight: "bold")[naładowane], więc oprócz zderzeń czują też siłę elektromagnetyczną.

		#v(5pt)
		To oznacza, że ich ruch zależy od pola magnetycznego, prądu, gradientów temperatury i gęstości. Zachowanie plazmy jest więc jednocześnie #text(weight: "bold")[mechaniczne], #text(weight: "bold")[termiczne] i #text(weight: "bold")[elektromagnetyczne].

		#v(5pt)
		#formula[$p approx n k_B T$]

		#v(4pt)
		Ta prosta zależność pokazuje pierwszą intuicję: jeśli rośnie gęstość $n$ albo temperatura $T$, rośnie ciśnienie plazmy, a więc także siła napędzająca transport.

		#v(4pt)
		#plain[Plazma bywa nazywana czwartym stanem materii. Nie dlatego, że jest „egzotyczna", ale dlatego, że klasyczne intuicje dla gazu przestają wystarczać.]
	],
	card("Co mierzymy w projekcie?", fill-color: sage)[
		Model PI-CVAE nie przewiduje pojedynczej liczby, lecz pełny stan lokalny plazmy w przekroju reaktora.

		#v(4pt)
		Najważniejsze wielkości to:
		- #text(weight: "bold")[$T_e$] i #text(weight: "bold")[$T_i$] — temperatury elektronów i jonów,
		- #text(weight: "bold")[$n_a$] — gęstości różnych gatunków jonów,
		- #text(weight: "bold")[$u_a$] — ich prędkości wzdłuż linii pola magnetycznego.

		#v(5pt)
		#formula[$n_e approx sum_a Z_a n_a$]

		#v(4pt)
		W skali płynowej plazma jest prawie #text(weight: "bold")[quasi-neutralna]: całkowity ładunek dodatni i ujemny niemal się równoważą. To właśnie dlatego zamiast śledzić każdą cząstkę osobno, można modelować pola ciągłe.

		#v(4pt)
		#plain[Każda z tych wielkości jest mapą 2D: pokazuje, gdzie plazma jest gorąca, gęsta, szybka lub rozrzedzona.]
	],
)
]

		// ══════════════════════════════════════════════════════════
		// SLAJD 1A — MAGNETYZACJA PLAZMY
		// ══════════════════════════════════════════════════════════

		#slide[
		#slide-title(
			"Dlaczego pole magnetyczne rządzi ruchem plazmy?",
			subtitle: "W tokamaku najważniejsza nie jest tylko temperatura, ale to, że naładowane cząstki są zmuszane do ruchu po złożonych orbitach wokół linii pola.",
		)

		#grid(
			columns: (1fr, 1fr),
			gutter: 15pt,
			card("Siła Lorenza", fill-color: teal)[
				Podstawowe równanie ruchu pojedynczej cząstki w plazmie ma postać:

				#v(5pt)
				#formula[$m d v / d t = q (E + v times B)$]

				#v(5pt)
				Człon elektryczny $q E$ przyspiesza cząstkę wzdłuż pola elektrycznego, a człon magnetyczny $q (v times B)$ zakrzywia tor ruchu prostopadle do prędkości i pola magnetycznego. W efekcie cząstka nie leci po prostej, lecz owija się wokół linii pola.

				#v(4pt)
				#plain[Pole magnetyczne nie ogrzewa plazmy bezpośrednio, ale kieruje ruchem cząstek i zamienia prosty przepływ w ruch spiralny.] 
			],
			card("Larmor i magnetyzacja", fill-color: sage)[
				Dla silnego pola magnetycznego powstaje szybki ruch kołowy o promieniu Larmora:

				#v(5pt)
				#formula[$r_L = m v_"perp" / (|q| B)$]

				#v(5pt)
				Im silniejsze pole $B$, tym mniejszy promień orbity i tym trudniej cząstce uciec w poprzek pola. To właśnie dlatego transport poprzeczny jest tłumiony, a dominują przepływy wzdłuż linii pola.

				#v(4pt)
				#formula[$u_"parallel" >> u_"perp"$]
			],
		)

		#v(10pt)

		#card("Konsekwencja dla tokamaka", fill-color: amber)[
			W tokamaku pole magnetyczne nie służy tylko do „trzymania plazmy w środku". Ono narzuca całą geometrię transportu: określa, gdzie energia odpływa, gdzie cząstki docierają do dywertora i dlaczego profile w SOL są tak wydłużone wzdłuż linii pola.

			#v(4pt)
			#plain[Jeśli chcemy modelować SOL, musimy myśleć nie tylko o temperaturze i gęstości, ale o tym, jak pole magnetyczne kanalizuje każdy strumień.]
		]
		]

// ══════════════════════════════════════════════════════════
// SLAJD 2 — TOKAMAK I SOL
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Tokamak i warstwa SOL",
	subtitle: "Najtrudniejsza fizyka nie dzieje się w spokojnym centrum, lecz na brzegu plazmy tuż przed kontaktem ze ścianą.",
)

#grid(
	columns: (1fr, 0.95fr),
	gutter: 15pt,
	[
		#card("Gdzie znajduje się SOL?", fill-color: amber)[
			W tokamaku plazma utrzymywana jest przez silne pole magnetyczne w kształcie torusa. Większość cząstek krąży po zamkniętych liniach pola, ale na brzegu pojawia się obszar, w którym linie przecinają powierzchnie materiałowe.

			#v(5pt)
			Ten obszar to #text(weight: "bold")[Scrape-Off Layer] — cienka, ale krytyczna warstwa przejściowa między gorącym rdzeniem a ścianką reaktora.

			#v(5pt)
			#formula[$q_"parallel" >> q_"perp"$]

			#v(4pt)
			Transport w SOL jest silnie anizotropowy: wzdłuż linii pola ciepło i cząstki poruszają się dużo łatwiej niż w poprzek pola magnetycznego. To właśnie dlatego geometria pola tak mocno kształtuje profile przy brzegu.

			#v(4pt)
			#plain[SOL działa jak strefa kontaktu: to tutaj energia i cząstki opuszczają plazmę i trafiają do materiałów reaktora.]
		]

		#v(10pt)

		#card("Dlaczego SOL jest tak ważny?", fill-color: teal)[
			- decyduje o #text(weight: "bold")[obciążeniu cieplnym] płytek dywertora,
			- wpływa na #text(weight: "bold")[erozję materiałów] i ich żywotność,
			- kontroluje #text(weight: "bold")[ucieczkę cząstek] z obszaru zamkniętego pola,
			- łączy fizykę transportu, neutralizacji, zderzeń i przepływu przyściennego.

			#v(4pt)
			#insight[Mała zmiana parametrów na brzegu może gwałtownie zmienić ilość ciepła trafiającego w ścianę. Dlatego szybki emulator SOL ma praktyczną wartość inżynierską.]
		]
	],
	[
		#card("Droga energii i cząstek", fill-color: navy)[
			#grid(
				columns: (1fr,),
				gutter: 4pt,
				compact-stage("1. Rdzeń", [tam zachodzi fuzja i powstaje energia], navy),
				compact-stage("2. Brzeg plazmy", [transport turbulentny przesuwa ciepło i cząstki na zewnątrz], teal),
				compact-stage("3. SOL", [pole magnetyczne prowadzi przepływ w stronę dywertora], sage),
				compact-stage("4. Ścianka", [materiał odbiera strumień energii i cząstek], amber),
			)
		]

		#v(10pt)

		#card("Dlaczego symulacja jest kosztowna?", fill-color: sage)[
			SOLPS-ITER rozwiązuje sprzężony układ równań transportu, energii i ruchu dla wielu gatunków. To nie jest pojedyncze równanie, lecz cały #text(weight: "bold")[ekosystem zależnych od siebie pól].

			#v(5pt)
			#formula[$"gęstość" <-> "temperatura" <-> "prędkość" <-> "strumień"$]

			#v(4pt)
			#plain[Jeżeli zmienimy jedno wymuszenie, na przykład moc grzewczą, zmienia się temperatura; z temperatury wynika prędkość dźwięku; ta wpływa na przepływ; ten z kolei na strumień do ściany.]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 2A — SHEATH I DYWERTOR
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Sheath, ekranowanie Debye'a i dywertor",
	subtitle: "Między plazmą a materiałem nie ma ostrej granicy. Powstaje cienka warstwa elektryczna, która reguluje dopływ cząstek do ściany.",
)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	[
		#card("Ekranowanie Debye'a", fill-color: teal)[
			Plazma jest prawie quasi-neutralna w skali makro, ale lokalne zaburzenia ładunku są szybko ekranowane przez ruch elektronów i jonów. Charakterystyczna skala tego ekranowania to długość Debye'a.

			#v(5pt)
			#formula[$lambda_D = sqrt(epsilon_0 k_B T_e / (n_e e^2))$]

			#v(4pt)
			Jeżeli interesująca nas skala jest dużo większa niż $lambda_D$, można używać opisu płynowego i traktować plazmę jako prawie obojętną elektrycznie.
		]

		#v(10pt)

		#card("Warstwa sheath", fill-color: sage)[
			Tuż przy ścianie elektrony uciekają łatwiej niż cięższe jony, więc tworzy się spadek potencjału. To pole elektryczne hamuje elektrony i przyspiesza jony w stronę materiału.

			#v(5pt)
			#formula[$e Delta phi_"sheath" approx T_e$]

			#v(4pt)
			To właśnie w pobliżu tej warstwy pojawia się sens fizyczny kryterium Bohma: jony muszą wejść do sheathu z odpowiednio uporządkowaną prędkością.
		]
	],
	[
		#card("Rola dywertora", fill-color: amber)[
			Dywertor jest zaprojektowaną powierzchnią, która przejmuje strumień ciepła i cząstek opuszczających zamknięte linie pola. Z punktu widzenia inżynierskiego to jeden z najbardziej obciążonych elementów całego reaktora.

			#v(5pt)
			#formula[$q_"target" = gamma n T c_s$]

			#v(4pt)
			Choć w prezentacji nie rozwiązujemy pełnej fizyki sheathu, ta zależność pokazuje intuicję: strumień energii na celu rośnie wraz z gęstością, temperaturą i prędkością wypływu.
		]

		#v(10pt)

		#insight[SOL jest ważny dlatego, że kończy się na materiale. Bez opisu sheathu i dywertora nie wiadomo, czy dana mapa plazmy oznacza bezpieczny reżim pracy, czy przeciążenie ściany.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 3A — RÓWNANIA PŁYNOWE
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Uproszczony opis płynowy plazmy",
	subtitle: "SOLPS i emulator nie śledzą pojedynczych cząstek, lecz pola makroskopowe spełniające równania ciągłości, ruchu i energii.",
)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 13pt,
	card("Równanie ciągłości", fill-color: teal)[
		Opisuje bilans liczby cząstek: ile ich wpływa, wypływa i skąd biorą się źródła lub straty.

		#v(5pt)
		#formula[$partial n / partial t + nabla dot (n u) = S$]

		#v(5pt)
		Gdy $S = 0$, liczba cząstek jest zachowana. W stanie ustalonym zmiana w czasie zanika, a najważniejszy staje się bilans strumieni przestrzennych.
	],
	card("Równanie ruchu", fill-color: sage)[
		Ruch plazmy wynika z konkurencji między gradientem ciśnienia, bezwładnością, zderzeniami i oddziaływaniem z polem magnetycznym.

		#v(5pt)
		#formula[$m n (partial u / partial t + u dot nabla u) = - nabla p + ...$]

		#v(5pt)
		W prezentacji nie rozwijamy wszystkich członów, ale ważna intuicja jest prosta: różnice ciśnienia napędzają przepływ, a pole magnetyczne narzuca jego geometrię.
	],
	card("Równanie energii", fill-color: amber)[
		Temperatura zmienia się przez przewodzenie, konwekcję, wymianę energii między gatunkami i źródła zewnętrzne.

		#v(5pt)
		#formula[$partial T / partial t + u dot nabla T approx nabla dot (chi nabla T) + P$]

		#v(5pt)
		To równanie tłumaczy, dlaczego profile temperatury są tak wrażliwe na moc grzewczą, transport turbulentny i warunki przy brzegu.
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 3AA — FORMALNY OPIS MHD / BRAGINSKII
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Formalny opis: MHD i płyny Braginskii",
	subtitle: "Na poziomie formalnym plazmę opisuje się jako ośrodek przewodzący z tensorowym transportem, anizotropią względem pola magnetycznego i sprzężeniem między bilansem pędu, energii oraz pola.",
)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	[
		#card("Jednopłynowe MHD", fill-color: teal)[
			W przybliżeniu MHD plazma traktowana jest jako pojedynczy przewodzący płyn opisany przez gęstość masy $rho$, prędkość $u$, ciśnienie $p$ i pole magnetyczne $B$.

			#v(5pt)
			#formula[$partial rho / partial t + nabla dot (rho u) = 0$]
			#formula[$rho (partial u / partial t + u dot nabla u) = - nabla p + J times B$]
			#formula[$partial B / partial t = nabla times (u times B - eta J)$]

			#v(5pt)
			To podejście dobrze oddaje globalną dynamikę przewodzącego płynu, ale w SOL jest często zbyt grube, bo gubi rozdział na elektrony, jony i procesy przyścienne.
		]

		#v(10pt)

		#card("Ogólne prawo Ohma", fill-color: navy)[
			W formalizmie MHD pojawia się też równanie wiążące prąd, pole elektryczne i ruch ośrodka:

			#v(5pt)
			#formula[$E + u times B = eta J - (1 / n e) nabla p_e + ...$]

			#v(5pt)
			Oznacza ono, że pole elektryczne nie jest dowolne: wynika z ruchu plazmy, oporu, gradientu ciśnienia elektronów i innych poprawek kinetycznych.
		]
	],
	[
		#card("Formalizm Braginskii", fill-color: sage)[
			W SOL częściej używa się opisu Braginskii: osobnych równań dla elektronów i jonów z anizotropowym transportem względem pola $B$. Dla każdego gatunku zapisuje się bilans liczby, pędu i energii.

			#v(5pt)
			#formula[$partial n_s / partial t + nabla dot (n_s u_s) = S_s$]
			#formula[$m_s n_s d u_s / d t = - nabla p_s - nabla dot Pi_s + q_s n_s (E + u_s times B) + R_s$]
			#formula[$(3 / 2) n_s d T_s / d t + p_s nabla dot u_s = - nabla dot q_s + Q_s$]

			#v(5pt)
			To już poziom, na którym widać lepkość, tarcie międzygatunkowe, anizotropię przewodnictwa i rozdział temperatur elektronów oraz jonów.

			#v(5pt)
			W bardziej jawnej postaci Braginskii rozpisuje właśnie dwa brakujące obiekty transportowe:
			#formula[$Pi_s = - eta_0 W_"parallel" - eta_1 W_"perp" - eta_2 W_"gyro"$]
			#formula[$q_s = - kappa_"parallel" nabla_"parallel" T_s - kappa_"perp" nabla_"perp" T_s + q_"cross"$]

			#v(4pt)
			Tensor $Pi_s$ opisuje lepkość plazmy, a $q_s$ strumień ciepła. W silnie namagnesowanej plazmie zwykle $kappa_"parallel" >> kappa_"perp"$, więc przewodzenie ciepła jest bardzo skuteczne wzdłuż linii pola, a silnie stłumione poprzecznie.
		]

		#v(10pt)

		#card("Dlaczego to ważne dla SOL?", fill-color: amber)[
			W warstwie brzegowej występują duże gradienty, silna anizotropia $q_"parallel" >> q_"perp"$, kontakt z neutralami i warunki przy materiale. Formalizm Braginskii zachowuje te efekty lepiej niż proste jednopłynowe MHD.

			#v(5pt)
			#formula[$W = nabla u + (nabla u)^T - (2 / 3) I nabla dot u$]

			#v(4pt)
			To właśnie z gradientów prędkości buduje się tensory naprężeń lepkich. Dzięki temu formalizm nie opisuje tylko „jak szybko płynie plazma", ale też jak ścinanie, kompresja i rozciąganie zmieniają bilans pędu i ogrzewanie lepkie.

			#v(4pt)
			#plain[W tym projekcie PI-CVAE nie rozwiązuje tych równań jawnie, ale uczy się map wygenerowanych przez solver, który reprezentuje właśnie taką wielogatunkową, anizotropową fizykę transportu.]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 3AB — NEUTRALE, REKOMBINACJA I PROMIENIOWANIE
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Neutrale, rekombinacja i promieniowanie w SOL",
	subtitle: "Na brzegu plazmy nie występują tylko jony i elektrony. Bardzo ważną rolę odgrywają też neutrale oraz procesy atomowe, które zmieniają bilans energii i liczby cząstek.",
)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 13pt,
	card("Neutrale", fill-color: teal)[
		Cząstki neutralne powstają przy ścianie, po rekombinacji albo przez odbicie od materiału. Ponieważ nie są związane z liniami pola magnetycznego, mogą przenikać poprzecznie tam, gdzie jony byłyby silnie ograniczone przez magnetyzację.

		#v(5pt)
		#formula[$partial n_0 / partial t + nabla dot (n_0 u_0) = S_"rec" - S_"ion"$]

		#v(5pt)
		Neutrale są więc pomostem między plazmą a materiałem: przenoszą masę, uczestniczą w jonizacji i wpływają na lokalne ochładzanie brzegu.
	],
	card("Jonizacja i rekombinacja", fill-color: sage)[
		Dwa kluczowe procesy atomowe to jonizacja i rekombinacja:

		#v(5pt)
		#formula[$A^0 + e -> A^+ + 2 e$]
		#formula[$A^+ + e -> A^0 + h nu$]

		#v(5pt)
		Jonizacja zwiększa liczbę naładowanych cząstek, a rekombinacja je usuwa. Oba procesy są silnie zależne od lokalnej temperatury i gęstości, więc mogą gwałtownie zmieniać profile w pobliżu dywertora.
	],
	card("Promieniowanie", fill-color: amber)[
		W SOL część energii nie trafia do ściany bezpośrednio jako przewodzenie lub konwekcja, lecz jest tracona przez emisję fotonów.

		#v(5pt)
		#formula[$P_"rad" approx n_e n_z L_z(T_e)$]

		#v(5pt)
		Ten człon opisuje straty radiacyjne zależne od gęstości elektronów, domieszek i temperatury. Silne promieniowanie może celowo obniżać obciążenie cieplne dywertora, ale jednocześnie komplikuje strukturę pola temperatury.
	],
)

#v(10pt)

#card("Znaczenie dla emulatora", fill-color: navy)[
	W praktyce neutrale, rekombinacja i promieniowanie są częścią „ukrytej fizyki" zawartej w danych SOLPS-ITER. Model PI-CVAE nie ma osobnego kanału dla neutrali, ale skutki tych procesów są zakodowane pośrednio w mapach temperatur, gęstości i prędkości, które sieć odtwarza. To ważne: nawet jeśli emulator nie rozwiązuje jawnie kinetyki atomowej, jego wyjście ma pozostać zgodne z rozwiązaniem, w którym te procesy już wpłynęły na końcowy stan SOL.
]
]

// ══════════════════════════════════════════════════════════
// SLAJD 3AC — DETACHED DIVERTOR I CHŁODZENIE RADIACYJNE
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Detached divertor i radiacyjne chłodzenie brzegu",
	subtitle: "Jednym z najważniejszych celów fizyki brzegu jest wejście w reżim, w którym część energii zostaje wypromieniowana lub rozproszona zanim dotrze do celu dywertora.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 13pt,
		stage-box(56mm, "Attached", [gorący, szybki strumień dociera bezpośrednio do dywertora], amber),
		[#arrow()],
		stage-box(56mm, "Promieniowanie", [domieszki i neutrale odbierają energię przez emisję i zderzenia], teal),
		[#arrow()],
		stage-box(56mm, "Detached", [plazma przy celu ochładza się i traci pęd przed kontaktem z materiałem], sage),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	[
		#card("Co znaczy detachment?", fill-color: teal)[
			W stanie #text(weight: "bold")[attached] gorąca plazma przewodzi ciepło wzdłuż linii pola niemal bezpośrednio do płytki dywertora. W stanie #text(weight: "bold")[detached] plazma przy celu staje się chłodniejsza, gęstsza i wolniejsza, a maksimum oddziaływania odsuwa się od materiału.

			#v(5pt)
			#formula[$q_"target"^"det" < q_"target"^"att", quad T_e^"det" < T_e^"att", quad p_"parallel"^"det" < p_"parallel"^"att"$]

			#v(4pt)
			To pożądany reżim, bo zmniejsza obciążenie cieplne ściany i ryzyko uszkodzenia materiału.
		]

		#v(10pt)

		#card("Jak powstaje chłodzenie radiacyjne?", fill-color: navy)[
			Część energii jest odbierana z plazmy przez wzbudzenia, jonizację, rekombinację i promieniowanie domieszek. Jeśli straty radiacyjne są wystarczająco silne, temperatura przy dywertorze spada, a przepływ jonów traci pęd.

			#v(5pt)
			#formula[$P_"loss" = P_"rad" + P_"ion" + P_"cx"$]

			#v(4pt)
			W praktyce duże znaczenie mają też zderzenia wymiany ładunku z neutralami, które odbierają pęd wypływającej plazmie.
		]
	],
	[
		#card("Formalne kryterium trendu", fill-color: amber)[
			Detachment nie ma jednej prostej definicji algebraicznej, ale formalnie rozpoznaje się go po jednoczesnym spadku temperatury przy celu, redukcji strumienia ciepła i utracie ciśnienia równoległego.

			#v(5pt)
			#formula[$nabla_"parallel" q_"parallel" = - P_"rad" - P_"atom" - ...$]
			#formula[$nabla_"parallel" p_"parallel" < 0$]

			#v(4pt)
			Jeżeli wzdłuż linii pola energia i pęd są wytracane szybciej, niż są dostarczane z upstreamu, plazma przy celu przechodzi w chłodniejszy i łagodniejszy reżim.
		]

		#v(10pt)

		#insight[Z punktu widzenia projektu to szczególnie ważne: emulator SOL powinien umieć odwzorować przejścia między reżimem attached i detached, bo właśnie tam małe zmiany parametrów dają duże zmiany obciążenia dywertora.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 3AD — ATTACHED VS PARTIALLY VS FULLY DETACHED
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Attached, partially detached i fully detached",
	subtitle: "Te trzy reżimy różnią się nie nazwą, lecz lokalnym bilansem energii, pędu i oddziaływania plazmy z płytką dywertora.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 13pt,
		stage-box(54mm, "Attached", [gorąca plazma i silny strumień energii dochodzą do celu], amber),
		[#arrow()],
		stage-box(54mm, "Partially detached", [chłodzenie zaczyna osłabiać strumień i przesuwa strefę emisji], teal),
		[#arrow()],
		stage-box(54mm, "Fully detached", [obszar przy celu jest chłodny, a główne straty zachodzą przed kontaktem z materiałem], sage),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 13pt,
	card("Attached", fill-color: amber)[
		- wysoka temperatura elektronów przy celu,
		- mała utrata ciśnienia równoległego,
		- duży $q_"target"$ i silne obciążenie materiału,
		- niewielki wpływ procesów radiacyjnych na końcowy strumień.

		#v(5pt)
		#formula[$T_e^"target" "high", quad p_"parallel"^"target" approx p_"parallel"^"upstream"$]
	],
	card("Partially detached", fill-color: teal)[
		- temperatura przy celu wyraźnie spada,
		- pojawia się częściowa utrata pędu przez zderzenia i neutrale,
		- maksimum promieniowania przesuwa się w górę linii pola,
		- strumień ciepła maleje, ale kontakt plazmy z celem nadal pozostaje istotny.

		#v(5pt)
		#formula[$q_"target"^"part" < q_"target"^"att", quad p_"parallel"^"part" < p_"parallel"^"att"$]
	],
	card("Fully detached", fill-color: sage)[
		- plazma przy celu jest chłodna i wolniejsza,
		- większość energii zostaje utracona wcześniej przez promieniowanie i procesy atomowe,
		- ciśnienie równoległe silnie spada,
		- obciążenie cieplne dywertora jest najmniejsze, ale sterowanie tym reżimem jest trudniejsze.

		#v(5pt)
		#formula[$T_e^"full" << T_e^"att", quad q_"target"^"full" << q_"target"^"att"$]
	],
)

#v(10pt)

#card("Jak czytać to porównanie?", fill-color: navy)[
	Przejście od `attached` do `fully detached` nie jest skokiem binarnym, lecz ciągłym procesem utraty energii i pędu wzdłuż linii pola. Reżim pośredni jest często najbardziej praktyczny eksperymentalnie: obciążenie cieplne już spada, ale sterowanie plazmą pozostaje łatwiejsze niż przy pełnym detachment. Z punktu widzenia emulatora to ważne, bo właśnie w tej przestrzeni przejść niewielka zmiana parametrów wejściowych może powodować jakościowo inną odpowiedź przy dywertorze.
]
]

// ══════════════════════════════════════════════════════════
// SLAJD 3B — ŹRÓDŁA I WARUNKI BRZEGOWE
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Źródła, zderzenia i warunki brzegowe",
	subtitle: "Pełny opis SOL wymaga nie tylko pól wewnątrz domeny, ale także informacji, jak plazma jest zasilana, ochładzana i zamykana na granicach.",
)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 13pt,
	card("Źródła i straty", fill-color: teal)[
		W równaniach transportu człony $S$ i $P$ reprezentują zasilanie plazmy, jonizację, rekombinację, promieniowanie oraz wymianę z neutralami.

		#v(5pt)
		#formula[$S = S_"ion" - S_"rec" + S_"ext"$]

		#v(5pt)
		To dzięki nim gęstość i temperatura nie są wyznaczane wyłącznie przez przepływ, ale również przez lokalne procesy atomowe i dopływ energii.
	],
	card("Zderzenia", fill-color: sage)[
		Elektrony, jony i neutrale zderzają się, wymieniając pęd i energię. W efekcie część ruchu jest uporządkowana przez pole magnetyczne, a część rozmywana przez kolizje.

		#v(5pt)
		#formula[$nu_"coll" = 1 / tau_"coll"$]

		#v(5pt)
		Stosunek częstości zderzeń do częstości żyromagnetycznej decyduje, czy transport jest bardziej swobodny, czy bardziej lepki i dyfuzyjny.
	],
	card("Warunki brzegowe", fill-color: amber)[
		Na krawędziach domeny trzeba określić, co wpływa do plazmy i co może ją opuścić. To właśnie warunki brzegowe sprzęgają rdzeń, SOL i powierzchnie materiałowe.

		#v(5pt)
		#formula[$f|_"boundary" = f_0 quad "lub" quad partial f / partial n = 0$]

		#v(5pt)
		Różne wybory warunków dają różne profile temperatury, gęstości i prędkości, nawet przy tych samych równaniach wewnątrz obszaru.
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 3 — JAKIE POLA OPISUJEMY?
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Jakie pola fizyczne opisuje model?",
	subtitle: "Każda próbka to zestaw 22 map: temperatur, gęstości i prędkości różnych składników plazmy.",
)

#card("Struktura danych fizycznych", fill-color: teal)[
	#grid(
		columns: (1.2fr, 0.8fr),
		gutter: 18pt,
		[
			W projekcie jedna symulacja SOL jest zapisana jako tensor #text(weight: "bold")[22 × 104 × 50]. Oznacza to 22 osobne mapy na tej samej siatce przestrzennej.

			#v(5pt)
			W tych 22 kanałach znajdują się:
			- #text(weight: "bold")[2 temperatury]: $T_e$, $T_i$,
			- #text(weight: "bold")[10 gęstości]: $n_a$ dla różnych gatunków,
			- #text(weight: "bold")[10 prędkości]: $u_a$ dla tych samych gatunków.

			#v(5pt)
			#plain[To jak 22 przezroczyste warstwy nałożone na ten sam przekrój tokamaka. Każda warstwa pokazuje inną własność fizyczną tego samego obszaru.]
		],
		[
			#v(8pt)
			#formula[$22 times 104 times 50$]
			#v(8pt)
			#align(center)[#tag("2 temperatury", fill-color: teal) #h(5pt) #tag("10 gęstości", fill-color: sage) #h(5pt) #tag("10 prędkości", fill-color: amber)]
		]
	)
]

#v(10pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Znaczenie temperatur i gęstości", fill-color: amber)[
		Temperatura mówi, ile energii kinetycznej mają cząstki. Gęstość mówi, ile cząstek znajduje się w danym miejscu. Razem odpowiadają na pytanie: #text(weight: "bold")[jak gorąca i jak „zatłoczona" jest plazma].

		#v(4pt)
		#formula[$p approx n_e T_e + n_i T_i$]

		#v(4pt)
		Wysoka temperatura zwiększa ruchliwość i wpływa na prędkość dźwięku w plazmie. Wysoka gęstość zwiększa strumień cząstek, jeśli prędkość pozostaje duża.

		#v(4pt)
		Ciśnienie jest tu kluczowym łącznikiem między mikrofizyką i transportem: z lokalnych pól $n$ i $T$ powstaje makroskopowy napęd przepływu.
	],
	card("Znaczenie prędkości", fill-color: sage)[
		Prędkość $u_a$ opisuje, jak szybko dany gatunek przemieszcza się wzdłuż linii pola. Sama gęstość nie mówi jeszcze, ile materii opuszcza dany obszar.

		#v(4pt)
		Dopiero iloczyn #text(weight: "bold")[$Gamma = n_a dot u_a$] daje #text(weight: "bold")[strumień cząstek] — czyli rzeczywisty przepływ materii przez plazmę.

		#v(4pt)
		W praktyce oznacza to, że dwa profile o podobnej temperaturze mogą mieć zupełnie inne skutki dla ściany, jeśli różnią się prędkościami dryfu i wypływu.

		#v(4pt)
		#plain[Duża gęstość i mała prędkość mogą dać ten sam strumień co mała gęstość i duża prędkość. Dlatego model musi znać oba pola jednocześnie.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 4 — TRANSPORT I STRUMIEŃ
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Transport, strumień i zasady zachowania",
	subtitle: "Rdzeń fizyki SOL to odpowiedź na pytanie: jak energia i cząstki przemieszczają się przez warstwę brzegową?",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 14pt,
		stage-box(62mm, "Gradient", [różnica temperatury lub gęstości tworzy „napęd" przepływu], amber),
		[#arrow()],
		stage-box(62mm, "Ruch cząstek", [jony i elektrony przyspieszają, zderzają się i dryfują], teal),
		[#arrow()],
		stage-box(62mm, "Strumień", [do ściany dociera konkretna ilość energii i materii na jednostkę czasu], sage),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Strumień cząstek", fill-color: teal)[
		#formula[$Gamma = n_a dot u_a$]

		Jeżeli w danym miejscu plazma jest gęsta i szybko płynie, strumień $Gamma$ jest duży. To właśnie strumień, a nie sama gęstość, decyduje o tym, ile cząstek uderza w powierzchnię materiału.

		#v(4pt)
		#formula[$q approx - chi nabla T$]

		#v(4pt)
		Analogicznie opisuje się transport energii: strumień ciepła płynie z obszarów gorących do chłodnych. SOL jest więc jednocześnie problemem transportu materii i transportu energii.

		#v(4pt)
		#plain[Strumień to odpowiednik przepływu wody w rurze: liczy się jednocześnie szerokość strumienia i szybkość ruchu.]
	],
	card("Zasada zachowania", fill-color: navy)[
		W obszarze bez źródeł i pochłaniaczy cząstki nie mogą znikać ani pojawiać się samoczynnie. Matematycznie oznacza to, że dywergencja strumienia powinna być bliska zeru.

		#v(5pt)
		#formula[$nabla dot (n_a u_a) approx 0$]

		#v(4pt)
		W wersji zależnej od czasu pełny zapis ma postać:
		#formula[$partial n_a / partial t + nabla dot (n_a u_a) = S_a$]

		#v(4pt)
		#plain[Jeśli do małego obszaru wpływa więcej cząstek niż wypływa, gęstość tam rośnie. Jeżeli bilans ma pozostać stabilny, wpływ i odpływ muszą się równoważyć.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 5 — TEMPERATURA I KRYTERIUM BOHMA
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Temperatura, prędkość dźwięku i kryterium Bohma",
	subtitle: "Przepływ przy brzegu plazmy nie jest dowolny: ogranicza go lokalna termodynamika i dynamika jonów.",
)

#grid(
	columns: (1fr, 0.95fr),
	gutter: 15pt,
	[
		#card("Skąd bierze się prędkość dźwięku w plazmie?", fill-color: amber)[
			Jeżeli plazma jest gorętsza, zaburzenia ciśnienia rozchodzą się szybciej. Dla jonów charakterystyczna skala prędkości zależy od temperatury elektronów i jonów oraz od masy cząstek.

			#v(5pt)
			#formula[$c_s = sqrt((T_e + T_i) / m)$]

			#v(4pt)
			W kodzie treningowym właśnie z tych pól liczona jest lokalna prędkość odniesienia używana w karze Bohma.

			#v(4pt)
			Jeżeli elektronowa i jonowa część plazmy są cieplejsze, wzrasta ciśnienie i łatwiej o szybki wypływ do warstwy przyściennej. Zależność z masą $m$ przypomina, że cięższe jony reagują wolniej.
		]

		#v(10pt)

		#card("Kryterium Bohma", fill-color: sage)[
			Na granicy z warstwą przyścienną jony muszą osiągać odpowiednio uporządkowany przepływ. Model penalizuje przypadki, w których prędkość jonów staje się niezgodna z dopuszczalną skalą wyznaczaną przez $c_s$.

			#v(5pt)
			#formula[$|u_a| lt.eq c_s$]

			#v(4pt)
			W języku fizycznym oznacza to, że przy przejściu do sheathu przepływ nie jest przypadkowy: musi dopasować się do lokalnej struktury pola i temperatur. Bohmowe ograniczenie wiąże więc hydrodynamikę z warunkiem brzegowym przy materiale.

			#v(4pt)
			#plain[To działa jak fizyczny limit prędkości. Sieć nie może dowolnie „przyspieszyć" plazmy, jeśli lokalna temperatura nie uzasadnia takiego ruchu.]
		]
	],
	[
		#insight[Temperatura i prędkość nie są niezależne. Gorętsza plazma może poruszać się szybciej, ale ta szybkość nadal musi być spójna z lokalnym stanem termicznym.]

		#v(10pt)

		#card("Dlaczego to ważne dla reaktora?", fill-color: navy)[
			Jeżeli model przewidywałby zbyt szybkie przepływy, zawyżałby strumień cząstek i mógłby fałszywie sugerować większe lub mniejsze zagrożenie dla dywertora.

			#v(4pt)
			Fizyczna kara stabilizuje więc nie tylko trening, ale także #text(weight: "bold")[wiarygodność interpretacji inżynierskiej].

			#v(4pt)
			#plain[W tym projekcie ML nie ma tworzyć ładnych obrazków, tylko pola zgodne z prawami ruchu plazmy.]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 6 — NIEUJEMNOŚĆ I SENS FIZYCZNY
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Nieujemność: najprostsze prawo, którego nie wolno złamać",
	subtitle: "Temperatura i gęstość mogą być małe, ale nie mogą być ujemne. To podstawowy filtr fizycznego sensu.",
)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 13pt,
	card("Temperatura", fill-color: teal)[
		Temperatura opisuje średnią energię ruchu cząstek. Ujemna temperatura w tym kontekście nie ma sensu fizycznego.

		#v(5pt)
		#formula[$T_e >= 0, quad T_i >= 0$]

		#v(4pt)
		#formula[$E_"kin" approx k_B T$]

		#v(5pt)
		#plain[Jeżeli model podałby wartość ujemną, znaczyłoby to, że tworzy obiekt matematyczny, a nie stan plazmy.]
	],
	card("Gęstość", fill-color: sage)[
		Gęstość to liczba cząstek w jednostce objętości. Nie może spaść poniżej zera, bo nie istnieje „minus trzy jony" w danym punkcie przestrzeni.

		#v(5pt)
		#formula[$n_a >= 0$]

		#v(4pt)
		#formula[$N = integral_V n_a d V >= 0$]

		#v(5pt)
		#plain[To jedno z tych ograniczeń, które są oczywiste dla fizyka, ale nie są oczywiste dla sieci neuronowej uczonej wyłącznie na liczbach.]
	],
	card("Znaczenie dla uczenia", fill-color: amber)[
		W skrypcie treningowym przewidywane pola są odnormalizowywane, a następnie sprawdzane pod kątem wartości ujemnych. Każde naruszenie zwiększa stratę.

		#v(5pt)
		To zmusza model do pozostawania w obszarze #text(weight: "bold")[fizycznie dopuszczalnych odpowiedzi], nawet jeśli czysto statystycznie inna odpowiedź dawałaby mały błąd MSE.
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 7 — FIZYKA W FUNKCJI STRATY
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Jak fizyka trafia do funkcji straty?",
	subtitle: "Model uczy się nie tylko zgadzać z danymi, ale też respektować zasady zachowania i ograniczenia dynamiczne.",
)

#card("Całkowita strata treningowa", fill-color: navy)[
	#grid(
		columns: (1.5fr, 1fr),
		gutter: 14pt,
		[
			#formula[$L = w_"rec" L_"rec" + beta_"KL" dot "KL"(q || p) + w_"nonneg" L_"nonneg" + w_"Bohm" L_"Bohm" + w_"div" L_"div"$]
			#v(5pt)
			#text(size: 10.2pt, fill: muted, style: "italic")[Rekonstrukcja pilnuje zgodności z danymi, KL pilnuje poprawnej przestrzeni latentnej, a trzy ostatnie składniki pilnują fizyki.]
		],
		[
			#insight[To nie jest „fizyka zamiast danych", lecz fizyka #text(weight: "bold")[razem z danymi]. Model dostaje swobodę tylko tam, gdzie prawa zachowania i ograniczenia lokalne na to pozwalają.]
		]
	)
]

#v(10pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Co oznacza każdy człon?", fill-color: teal)[
		- #text(weight: "bold")[$L_"rec"$] — czy odtworzone mapy są podobne do SOLPS,
		- #text(weight: "bold")[KL] — czy latentne opisy są zgodne z priorem warunkowym,
		- #text(weight: "bold")[$L_"nonneg"$] — czy temperatury i gęstości są nieujemne,
		- #text(weight: "bold")[$L_"Bohm"$] — czy prędkości są zgodne z lokalnym stanem termicznym,
		- #text(weight: "bold")[$L_"div"$] — czy strumień nie łamie zasady zachowania.

		#v(5pt)
		#formula[$L_"div" approx <(nabla dot (n_a u_a))^2>$]
		#formula[$L_"Bohm" approx <"ReLU"(|u_a| - c_s)^2>$]
	],
	card("Po co te wagi?", fill-color: amber)[
		Nie wszystkie błędy mają taki sam koszt. Wagi $w$ pozwalają zdecydować, jak mocno karać różne typy naruszeń.

		#v(4pt)
		Jeżeli kara fizyczna byłaby zbyt słaba, model mógłby dawać piękne, lecz nieprawdziwe mapy. Gdyby była zbyt silna, model przestałby dobrze dopasowywać dane.

		#v(4pt)
		#plain[Trening to kompromis: model ma być jednocześnie wierny symulacjom i posłuszny fizyce.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 8 — OD PARAMETRÓW REAKTORA DO MAP SOL
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Od parametrów reaktora do map SOL",
	subtitle: "Osiem liczb warunków globalnych wystarcza, aby zawęzić realistyczne stany plazmy do małego obszaru przestrzeni możliwości.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 14pt,
		stage-box(63mm, [#icon-tag("c", amber) #h(5pt) 1. Warunki], [moc grzewcza, pole magnetyczne, zasilanie i inne parametry globalne], amber),
		[#arrow()],
		stage-box(63mm, [#icon-tag("p", sage) #h(5pt) 2. Prior], [sieć uczy się, jaki zakres stanów jest wtedy możliwy], sage),
		[#arrow()],
		stage-box(63mm, [#icon-tag("SOL", teal) #h(5pt) 3. Mapy], [dekoder generuje temperatury, gęstości i prędkości na całym przekroju], teal),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Fizyka ukryta w warunkach globalnych", fill-color: sage)[
		Model dostaje 8 liczb opisujących stan eksperymentu. Nie są one mapami, ale niosą informację o tym, w jakim reżimie pracuje reaktor.

		#v(4pt)
		Jeśli zwiększymy moc, zwykle rosną temperatury. Jeśli zmienimy pole magnetyczne, zmieniamy sposób prowadzenia cząstek. Jeśli zmienimy warunki zasilania, zmienia się bilans gęstości.

		#v(5pt)
		#formula[$x_"cond" in RR^8 -> p(z | c) -> x_"rec" in RR^(22 times 104 times 50)$]

		#v(4pt)
		#plain[Prior warunkowy jest więc fizyczną intuicją modelu: „przy takich nastawach spodziewam się takich stanów SOL".]
	],
	card("Dlaczego to użyteczne?", fill-color: navy)[
		Po wytrenowaniu nie trzeba uruchamiać pełnej symulacji dla każdej kombinacji parametrów. Wystarczy podać nowe warunki, a model natychmiast generuje realistyczne pola.

		#v(4pt)
		To otwiera drogę do:
		- szybkiego przeszukiwania przestrzeni parametrów,
		- analizy wrażliwości,
		- wsparcia projektowania bez godzin oczekiwania na SOLPS-ITER.
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 9 — DLACZEGO TO NIE JEST ZWYKŁY ML?
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Dlaczego to nie jest zwykły model ML?",
	subtitle: "PI-CVAE nie tylko interpoluje dane. Ma odtwarzać stany plazmy, które nadal są zgodne z podstawowymi prawami fizyki.",
)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	[
		#card("Czysto statystyczny model", fill-color: amber)[
			Minimalizuje błąd względem danych i może nauczyć się bardzo dobrego dopasowania średniego.

			#v(4pt)
			Ale bez ograniczeń może tworzyć pola:
			- z ujemną gęstością,
			- z niefizycznie szybkim przepływem,
			- z naruszeniem bilansu strumienia.

			#v(4pt)
			#plain[Dla obrazu komputerowego to może być akceptowalne. Dla plazmy w reaktorze już nie.]
		]
	],
	[
		#card("Physics-Informed model", fill-color: teal)[
			Dane mówią modelowi #text(weight: "bold")[jak wyglądają] realistyczne przypadki, a fizyka mówi #text(weight: "bold")[jakie odpowiedzi są dozwolone].

			#v(4pt)
			Dzięki temu wynik jest jednocześnie:
			- szybki,
			- gładki statystycznie,
			- interpretowalny fizycznie,
			- użyteczny dla dalszej analizy reaktora.

			#v(4pt)
			#insight[To najważniejsza idea całego projektu: przyspieszyć symulację, ale nie zgubić sensu fizycznego.]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 10 — PODSUMOWANIE
// ══════════════════════════════════════════════════════════

#slide[
#slide-title("Najważniejsze idee fizyczne")

#v(2pt)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 11pt,
	card("SOL to strefa krytyczna", fill-color: teal)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		To na brzegu plazmy decyduje się, ile energii i materii trafi do ścian reaktora. Dlatego właśnie tę strefę warto emulować szybko i wiarygodnie.
	],
	card("Model przewiduje pełny stan lokalny", fill-color: sage)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		PI-CVAE generuje 22 mapy: temperatury, gęstości i prędkości. Dzięki temu opisuje nie tylko „ile", ale też „gdzie" i „jak szybko" dzieje się transport.
	],
	card("Fizyka ogranicza rozwiązania", fill-color: amber)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		Nieujemność, kryterium Bohma i zachowanie strumienia sprawiają, że wynik nie jest przypadkowym obrazem, lecz kandydatem na realny stan plazmy.
	],
)

#v(8pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 11pt,
	card("Jedno zdanie o fizyce projektu", fill-color: navy)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		Projekt opisuje transport plazmy w warstwie SOL tokamaka: z temperatur, gęstości i prędkości różnych gatunków odtwarzany jest przepływ energii i cząstek ku ścianie, a wbudowane prawa fizyki pilnują, by te pola pozostawały realistyczne.
	],
	card("Jedno zdanie o roli PI-CVAE", fill-color: teal)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		PI-CVAE uczy się zastępować kosztowny solver SOLPS-ITER szybkim emulatorem, który nie tylko naśladuje dane, ale zachowuje podstawowe reguły fizyczne potrzebne do sensownej analizy reaktora fuzyjnego.
	],
)

#v(8pt)

#card("Pełny obraz fizyczny", fill-color: amber)[
	#set text(size: 9.8pt)
	#set par(leading: 1.0em)
	Pełny łańcuch fizyczny wygląda więc tak: energia fuzji i ogrzewania kształtuje temperatury i ciśnienia w plazmie; pole magnetyczne porządkuje ruch naładowanych cząstek i kieruje transportem głównie wzdłuż linii pola; w warstwie SOL zachodzą jednocześnie przewodzenie, konwekcja, zderzenia i procesy atomowe; na granicy z materiałem pojawiają się sheath i warunki Bohma; a ostatecznie to lokalne pola $T_e$, $T_i$, $n_a$ i $u_a$ decydują o strumieniu energii i materii trafiającym do dywertora. Model PI-CVAE uczy się tego obrazu w postaci map, a narzucone kary fizyczne pilnują, by wygenerowane rozwiązania pozostały zgodne z tym łańcuchem zależności.
]
]
