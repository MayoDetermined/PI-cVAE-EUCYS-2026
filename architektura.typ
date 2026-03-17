// ──────────────────────────────────────────────────────────
//  PI-CVAE · Architektura modelu  —  EUCYS 2026
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
			text(size: 7.5pt, fill: rgb("#9aa0b0"), tracking: 0.6pt)[PI-CVAE  ·  Architektura modelu],
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

// ─── Paleta kolorów ──────────────────────────────────────

#let navy   = rgb("#5b7fa6")
#let teal   = rgb("#6bafcc")
#let amber  = rgb("#d4a46a")
#let sage   = rgb("#7bbf96")
#let ink    = rgb("#2c3040")
#let muted  = rgb("#6b7488")
#let subtle = rgb("#9aa0b0")
#let border = rgb("#e0e2ea")
#let soft   = white

// ─── Komponent: Slajd (izolowana strona) ─────────────────

#let slide(body) = page(body)

// ─── Komponent: Tytuł slajdu ─────────────────────────────

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

// ─── Komponent: Karta (główna) ───────────────────────────
//  Nowoczesna karta z kolorowym paskiem na górze, zaokrąglone rogi.

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

// ─── Komponent: Callout „Innymi słowy" ───────────────────

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

// ─── Komponent: Insight (bursztynowy) ────────────────────

#let insight(body) = block(
	width: 100%,
	inset: (left: 15pt, right: 13pt, top: 10pt, bottom: 10pt),
	radius: 8pt,
	breakable: false,
	fill: rgb("#fdf5ea"),
	stroke: (
		left:  (paint: amber, thickness: 3pt),
		rest:  (paint: amber.lighten(65%), thickness: 0.35pt),
	),
	[
		#set par(justify: true)
		#text(size: 9.5pt, fill: amber)[◆] #h(4pt)
		#text(size: 10.8pt, style: "italic", fill: rgb("#8a6530"))[#body]
	],
)

// ─── Komponent: Stage-box (blok etapu) ───────────────────

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

// ─── Komponent: Tag (etykieta) ───────────────────────────

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

// ─── Komponent: Strzałka ────────────────────────────────

#let arrow() = align(center + horizon)[
	#box(inset: (x: 3pt))[
		#text(size: 17pt, fill: rgb("#c0c4d0"), baseline: -0.5pt)[⟶]
	]
]

// ─── Komponent: Stage w ramce o danej szerokości ─────────

#let stage-box(width, title, subtitle, fill-color) = align(center)[
	#block(width: width)[
		#stage(title, subtitle, fill-color)
	]
]

// ─── Komponent: Formuła (blok równania) ──────────────────

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
	// Subtle diagonal decoration
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
			#text(size: 54pt, weight: "bold", fill: white, tracking: 2pt)[PI–CVAE]
			#v(12pt)
			#text(size: 15.5pt, fill: rgb("#bdd6ec"), style: "italic")[Physics-Informed Conditional Variational Autoencoder]
			#v(7pt)
			#text(size: 12pt, fill: rgb("#95b8d2"))[do generacji pól plazmowych SOLPS-ITER]
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
					#text(size: 8.8pt, fill: rgb("#bdd6ec"), weight: "bold", tracking: 0.3pt)[CNN + Transformer]
				],
				rect(inset: (x: 13pt, y: 6pt), radius: 999pt, fill: rgb("#4a6a8d"), stroke: (paint: rgb("#5e80a5"), thickness: 0.6pt))[
					#text(size: 8.8pt, fill: rgb("#bdd6ec"), weight: "bold", tracking: 0.3pt)[Przestrzeń latentna 128]
				],
				rect(inset: (x: 13pt, y: 6pt), radius: 999pt, fill: rgb("#4a6a8d"), stroke: (paint: rgb("#5e80a5"), thickness: 0.6pt))[
					#text(size: 8.8pt, fill: rgb("#bdd6ec"), weight: "bold", tracking: 0.3pt)[Straty fizyczne]
				],
			)
			#v(38pt)
			#text(size: 9.5pt, fill: rgb("#7a9eb8"), tracking: 2pt)[ARCHITEKTURA MODELU — PRZEGLĄD]
		]
	]
]

#counter(page).update(1)

// ══════════════════════════════════════════════════════════
// SLAJD 1 — MOTYWACJA
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Motywacja: po co emulator plazmy?",
	subtitle: "PI-CVAE to sieć neuronowa zastępująca kosztowne obliczenia numeryczne błyskawicznym przewidywaniem.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 14pt,
		stage-box(66mm, "Problem", [Symulator SOLPS-ITER oblicza fizykę plazmy równaniami różniczkowymi — jedno uruchomienie trwa #text(weight: "bold")[wiele godzin]], amber),
		[#arrow()],
		stage-box(66mm, "Rozwiązanie", [Sieć neuronowa uczy się wzorców z tysięcy gotowych symulacji i odpowiada w #text(weight: "bold")[ułamku sekundy]], teal),
		[#arrow()],
		stage-box(66mm, "Zastosowanie", [Szybka optymalizacja parametrów reaktora i analiza wrażliwości bez uruchamiania SOLPS], sage),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Kontekst fizyczny", fill-color: teal)[
		#text(weight: "bold")[Tokamak] to reaktor fuzji jądrowej — w nim wodór podgrzewany jest do temperatury wyższej niż wnętrze Słońca i utrzymywany silnym polem magnetycznym.
		Strefa #text(weight: "bold")[SOL (Scrape-Off Layer)] to cienka warstwa plazmy tuż przed ścianką reaktora, kluczowa dla jego bezpieczeństwa i wydajności.

		#v(5pt)
		#text(weight: "bold")[SOLPS-ITER] to profesjonalny program numeryczny symulujący fizykę tej strefy — jednak jego uruchomienie trwa godziny, a optymalizacja wymaga tysięcy takich obliczeń.
	],
	card("Co to jest sieć neuronowa?", fill-color: sage)[
		#text(weight: "bold")[Sieć neuronowa] to program komputerowy uczący się wzorców z danych — podobnie jak dziecko uczy się rozpoznawać koty z tysięcy zdjęć, sieć uczy się przewidywać wyniki SOLPS na podstawie gotowych symulacji.

		#v(4pt)
		PI-CVAE przyjmuje #text(weight: "bold")[8 liczb] opisujących warunki eksperymentu (np. moc grzewcza w MW, natężenie pola magnetycznego w T) i generuje #text(weight: "bold")[22 mapy] rozkładu temperatury, gęstości i prędkości plazmy na przekroju SOL.

		#v(4pt)
		#plain[Zamiast liczyć fizykę od nowa, model „przypomina sobie" podobne przypadki ze zbioru treningowego i interpoluje odpowiedź.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 2 — ARCHITEKTURA: PRZEGLĄD
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"PI-CVAE: architektura modelu",
	subtitle: "Model zbudowany jest z trzech współpracujących modułów: enkodera, prioru i dekodera.",
)

#card("Dane wejściowe i wyjściowe", fill-color: teal)[
	#grid(
		columns: (1.25fr, 0.75fr),
		gutter: 18pt,
		[
			Model przyjmuje #text(weight: "bold")[22 mapy fizyczne plazmy] na siatce 104×50 punktów oraz #text(weight: "bold")[8 liczb] opisujących globalny stan reaktora — i generuje 22 mapy z powrotem.

			#v(5pt)
			#text(weight: "bold")[22 mapy] to: temperatura elektronów i jonów ($T_e, T_i$), gęstości 10 gatunków jonów ($n_a$) i ich prędkości ($u_a$). Każda mapa to obraz 104×50 — jak czarno-biała fotografia przekroju SOL.

			#v(5pt)
			#plain[Tensor 22×104×50 to po prostu 22 takich fotografii ułożonych w stos — jak strony atlasu anatomicznego, gdzie każda strona pokazuje inną wielkość fizyczną.]
		],
		[
			#v(8pt)
			#formula[$22 times 104 times 50$]
			#v(8pt)
			#align(center)[#tag("22 kanały", fill-color: sage) #h(6pt) #tag("104 × 50", fill-color: amber)]
		]
	)
]

#v(10pt)

#grid(
	columns: (1fr, 0.95fr),
	gutter: 15pt,
	[
		#card("Główna idea — trzy moduły", fill-color: amber)[
			#text(weight: "bold")[Physics-Informed Conditional VAE] łączy trzy moduły:

			- #text(weight: "bold")[Enkoder] — analizuje wejściowe mapy i streszcza je do krótkiego wektora liczb,
			- #text(weight: "bold")[Prior] — przewiduje, jak ten skrót powinien wyglądać na podstawie samych warunków globalnych,
			- #text(weight: "bold")[Dekoder] — na podstawie skrótu i warunków odtwarza pełne mapy.

			#v(4pt)
			#plain[Enkoder i dekoder działają jak para „koder–dekoder" w kompresji danych: jeden ściska, drugi rozpakowuje.]
		]
	],
	[
		#card("Kolejność operacji", fill-color: navy)[
			#grid(
				columns: (1fr, 1fr),
				gutter: 5pt,
				[
					#grid(
						columns: (1fr,),
						gutter: 3pt,
						micro-stage([#icon-tag("IN", amber) #h(4pt) 1. Wejście], [22 mapy + 8 liczb stanu], amber),
						micro-stage("2. Enkoder", [streszcza dane do $z$], teal),
						micro-stage("3. Prior", [przewiduje zakres $z$], sage),
					)
				],
				[
					#grid(
						columns: (1fr,),
						gutter: 3pt,
						micro-stage([#icon-tag("z", sage) #h(4pt) 4. Dekoder], [z $z$ i warunków odtwarza mapy], amber),
						micro-stage([#icon-tag("OUT", amber) #h(4pt) 5. Wyjście], [22 mapy 104 × 50], amber),
					)
				],
			)
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 3 — SCHEMAT OGÓLNY
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Schemat ogólny",
	subtitle: "Model przetwarza dane w trzech etapach: wczytanie → kompresja do reprezentacji wewnętrznej → odtworzenie.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto),
		column-gutter: 15pt,
		stage-box(65mm, [#icon-tag("IN", amber) #h(6pt) 1. Dane wejściowe], [22 mapy plazmy + 8 liczb (warunki reaktora)], amber),
		[#arrow()],
		stage-box(65mm, [#icon-tag("z", sage) #h(6pt) 2. Kompresja], [model zapisuje esencję stanu w 128 liczbach], sage),
		[#arrow()],
		stage-box(65mm, [#icon-tag("OUT", teal) #h(6pt) 3. Rekonstrukcja], [z 128 liczb odtwarzane są pełne mapy], teal),
	)
]

#v(12pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	card("Co wchodzi do modelu?", fill-color: teal)[
		- #text(weight: "bold")[$T_e, T_i$] — temperatura elektronów i jonów (w elektronowoltach),
		- #text(weight: "bold")[$n_a$ × 10] — gęstości różnych gatunków jonów (w m${}^(-3)$),
		- #text(weight: "bold")[$u_a$ × 10] — prędkości jonów wzdłuż linii pola (w m/s),
		- #text(weight: "bold")[$x_"cond"$ × 8] — warunki globalne: moc grzewcza, pole magnetyczne, gęstość wejściowa i inne.

		#v(5pt)
		#plain[Każda z 22 map to „termiczny obraz" innej wielkości fizycznej — razem tworzą kompletny opis stanu SOL.]
	],
	card("Co znaczy \"reprezentacja latentna\"?", fill-color: sage)[
		Model nie zapamiętuje 22 pełnych map — sprowadza je do #text(weight: "bold")[128 liczb] ($z in RR^128$) opisujących esencję stanu plazmy.

		#v(5pt)
		#plain[Analogia: zamiast pamiętać pełny atlas anatomiczny pacjenta, lekarz zapisuje w karcie kilka kluczowych parametrów (temperatura, ciśnienie, wyniki badań). Dekoder to lekarz, który z tych skrótów odtwarza pełny obraz stanu zdrowia.]

		#v(5pt)
		#text(size: 10.5pt, style: "italic")[Model jest #text(weight: "bold")[rekonstruktorem]: wyjście ma taki sam kształt jak wejście — nie klasyfikuje danych, lecz odtwarza je z kompresji.]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 4 — ROLA POSZCZEGÓLNYCH BLOKÓW
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Rola poszczególnych bloków",
	subtitle: "Enkoder przetwarza dane, prior wyraża oczekiwania, a dekoder odtwarza obrazy fizyczne.",
)

#align(center)[
	#grid(
		columns: (auto, auto, auto, auto, auto, auto, auto),
		column-gutter: 8pt,
		stage-box(44mm, "Enkoder", [analizuje mapy i wyciąga to, co istotne], teal),
		[#arrow()],
		stage-box(44mm, [#icon-tag("z", sage) #h(6pt) Wektor latentny], [128 liczb = „streszczenie" stanu], sage),
		[#arrow()],
		stage-box(44mm, "Prior", [sprawdza, czy streszczenie pasuje do warunków], sage),
		[#arrow()],
		stage-box(44mm, [#icon-tag("OUT", amber) #h(6pt) Dekoder], [ze streszczenia odtwarza pełne mapy 2D], amber),
	)
]

#v(10pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	[
		#card("Co robi każdy moduł?", fill-color: amber)[
			#set text(size: 10.5pt)
			#set par(leading: 1.05em, justify: true)
			- #text(weight: "bold")[Enkoder] przegląda 22 mapy i wydobywa z nich cechy charakterystyczne — jak ekspert analizujący wyniki badań.
			- #text(weight: "bold")[Wektor latentny $z$] to wynik tej analizy: 128 liczb opisujących stan plazmy — jak streszczenie artykułu zamiast całego tekstu.
			- #text(weight: "bold")[Prior] wyraża oczekiwania: wiedząc, jakie są warunki globalne (8 liczb), model przewiduje, jak $z$ powinno wyglądać.
			- #text(weight: "bold")[Dekoder] działa odwrotnie: z $z$ i warunków rekonstruuje 22 pełne mapy.
		]
	],
	[
		#card("Pytania, na które odpowiada architektura", fill-color: navy)[
			#set text(size: 10.3pt)
			#set par(leading: 1.02em, justify: true)
			- #text(weight: "bold")[Enkoder]: Które cechy map plazmy są najważniejsze dla opisu stanu SOL?
			- #text(weight: "bold")[$z$]: Jak zakodować kompletną wiedzę o stanie plazmy w 128 liczbach?
			- #text(weight: "bold")[Prior]: Jakich wartości $z$ spodziewamy się przy danych warunkach reaktora?
			- #text(weight: "bold")[Dekoder]: Jak z tego kodu odtworzyć pełny, fizycznie poprawny obraz SOL?

			#v(4pt)
			#text(size: 10pt, style: "italic", fill: sage)[Razem tworzą zamkniętą pętlę: ściskaj → sprawdź spójność → rozpakowuj.]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 5 — PRZEPŁYW DANYCH
// ══════════════════════════════════════════════════════════

#slide[#slide-title(
	"Przepływ danych przez model",
	subtitle: "W fazie treningu enkoder jest aktywny; w fazie generacji pomijamy go i próbkujemy z prioru.",
)

#grid(
	columns: (1fr, auto),
	gutter: 14pt,
	[
		#align(center)[
			#grid(
				columns: (auto, auto, auto, auto, auto),
				column-gutter: 9pt,
				stage-box(45mm, [#icon-tag("IN", amber) #h(5pt) Wejście pól], [22 mapy, tensor 22 × 104 × 50], amber),
				[#arrow()],
				stage-box(45mm, "Enkoder", [CNN + Transformer wyciąga cechy], teal),
				[#arrow()],
				stage-box(45mm, "Posterior", [$q(mu, sigma^2)$ — opis rozkładu $z$ z DANYCH], sage),
			)
		]

		#v(8pt)

		#align(center)[
			#grid(
				columns: (auto, auto, auto, auto, auto),
				column-gutter: 9pt,
				stage-box(45mm, "Warunki", [$x_"cond"$ — 8 liczb opisujących stan reaktora], amber),
				[#arrow()],
				stage-box(45mm, "PriorNet", [$p(mu, sigma^2 | c)$ — opis rozkładu $z$ z WARUNKÓW], sage),
				[#arrow()],
				stage-box(45mm, [#icon-tag("z", sage) #h(5pt) Próbkowanie $z$], [losowanie z rozkładu (reparametryzacja)], sage),
			)
		]

		#v(8pt)

		#align(center)[
			#grid(
				columns: (auto, auto, auto, auto, auto),
				column-gutter: 9pt,
				stage-box(45mm, [#icon-tag("z", sage) #h(5pt) $z$ + warunki $c$], [konkatenacja wektora $z$ z 8 liczbami], navy),
				[#arrow()],
				stage-box(45mm, "Dekoder", [dekonwolucje + bloki residualne], teal),
				[#arrow()],
				stage-box(45mm, [#icon-tag("OUT", amber) #h(5pt) Wyjście], [22 zrekonstruowane mapy SOL], amber),
			)
		]
	],
	[
		#block(width: 55mm)[
			#card("Trening vs generacja", fill-color: teal)[
				#text(size: 10.5pt)[
					#text(weight: "bold", fill: teal)[Podczas treningu]\
					Enkoder patrzy na prawdziwe mapy i wyznacza rozkład $q$ opisujący, „czym jest $z$". Model uczy się, by $q$ był bliski priorowi $p$.

					#v(6pt)
					#text(weight: "bold", fill: amber)[Podczas generacji]\
					Enkoder jest wyłączony. Model losuje $z$ z prioru $p(z|c)$ — tj. na podstawie samych warunków — i dekoduje nowe mapy.

					#v(6pt)
					#plain[To jak uczenie się od gotowych przykładów (trening), a potem samodzielne tworzenie nowych odpowiedzi (generacja).]
				]
			]
		]
	]
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 6 — FIZYKA WBUDOWANA W MODEL
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Fizyka wbudowana w model",
	subtitle: "Trzy człony kary w funkcji straty nie pozwalają sieci generować fizycznie niemożliwych wyników.",
)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 13pt,
	card("Nieujemność", fill-color: teal)[
		Temperatura i gęstość plazmy nigdy nie mogą być ujemne — to fundamentalne prawo fizyki.

		#v(5pt)
		#formula[$T_e, T_i >= 0, quad n_a >= 0$]

		#v(5pt)
		#plain[Bez tej kary sieć mogłaby generować „ujemną gęstość" — liczby matematycznie sensowne, ale fizycznie bezsensowne. Kara wymusza poprawność.]
	],
	card("Kryterium Bohma", fill-color: sage)[
		Jony w SOL nie mogą poruszać się szybciej niż prędkość dźwięku w plazmie ($c_s$) — tak jak przepływ gazów w zwężeniu.

		#v(5pt)
		#formula[$|u_a| lt.eq c_s = sqrt((T_e + T_i) \/ m)$]

		#v(5pt)
		#plain[To odpowiednik ograniczenia prędkości: jony przyspieszają, ale na granicy reaktora nie przekraczają „bariery dźwięku plazmy".]
	],
	card("Zachowanie strumienia", fill-color: amber)[
		Strumień cząstek $Gamma = n dot u$ powinien być bezrozbieżny — cząstki nie mogą „znikać" ani „pojawiać się" bez źródła.

		#v(5pt)
		#formula[$nabla dot (n_a u_a) approx 0$]

		#v(5pt)
		#plain[Analogia: jeśli tyle samo wody wpływa rurą co wypływa, dywergencja strumienia jest zerowa. Model uczy się tej zasady zachowania.]
	],
)

#v(12pt)

#card("Całkowita funkcja straty — co model minimalizuje podczas treningu?", fill-color: navy)[
	#grid(
		columns: (1.5fr, 1fr),
		gutter: 14pt,
		[
			#formula[$L = underbrace(L_"rec", "rekonstrukcja") + beta_"KL" dot underbrace("KL"(q || p), "spójność") + w_1 underbrace(L_"nonneg", "fizyka 1") + w_2 underbrace(L_"Bohm", "fizyka 2") + w_3 underbrace(L_"div", "fizyka 3")$]
			#v(5pt)
			#text(size: 10.2pt, fill: muted, style: "italic")[$L_"rec"$ — jak bardzo mapy różnią się od oryginału; KL — czy rozkład $z$ pasuje do prioru; $w_1, w_2, w_3$ — wagi kar fizycznych.]
		],
		[
			#insight[$beta_"KL"$ rośnie od 0 do 1 przez pierwsze 50 epok (KL annealing) — model uczy się najpierw rekonstruować, a dopiero potem spełniać ograniczenia statystyczne.]
		]
	)
]
]

// ══════════════════════════════════════════════════════════
// SLAJD 7 — ENKODER HYBRYDOWY
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Enkoder hybrydowy: CNN + Transformer",
	subtitle: "Dwa uzupełniające się mechanizmy: CNN widzi lokalne wzorce, Transformer — globalne zależności.",
)

#grid(
	columns: (1fr, 0.9fr),
	gutter: 16pt,
	[
		#card("Część CNN — lokalne cechy przestrzenne", fill-color: teal)[
			#text(weight: "bold")[Splotowa sieć neuronowa (CNN)] przesuwa małe „okno" po mapie i wykrywa lokalne wzorce (gradienty temperatury, fronty gęstości). Każda warstwa patrzy na coraz szerszy obszar:

			#v(4pt)
			Conv2d: 22 → 64 → 128 → 256 → 512 kanałów (stride 2 = zmniejsza rozmiar ×2 co warstwę)

			#v(4pt)
			Po każdej warstwie: #tag("GroupNorm — stabilizacja uczenia", fill-color: teal) #h(4pt) #tag("ReLU — nieliniowość", fill-color: sage)

			#v(4pt)
			#plain[CNN działa jak lekarz przeglądający zdjęcie RTG — najpierw widzi ostre krawędzie, potem rozpoznaje większe struktury.]
		]

		#v(11pt)

		#card("Część Transformer — globalne zależności", fill-color: navy)[
			Mapy ze 512 kanałami są rozkładane w sekwencję tokenów (jak piksele w obrazie zamieniają się w „słowa"):

			#v(3pt)
			#formula[$512 times H times W -> (H dot W) times 512$]

			#v(4pt)
			2 warstwy Transformer z mechanizmem #text(weight: "bold")[self-attention]: każdy token pyta pozostałe o ich wartość. Wynik: 512-wymiarowy wektor globalny.

			#v(4pt)
			#plain[Transformer widzi cały przekrój SOL jednocześnie — temperatura przy ściance może wpływać na interpretację gęstości w centrum.]
		]
	],
	[
		#insight[CNN widzi drzewo, Transformer widzi las. Łącząc oba, enkoder rozumie zarówno lokalne struktury SOL jak i spójność globalną całego profilu.]

		#v(10pt)

		#card("Wyjście enkodera — parametry rozkładu", fill-color: amber)[
			512-wymiarowy wektor przechodzi przez dwie warstwy liniowe, wyznaczając parametry rozkładu normalnego:

			#v(5pt)
			#formula[$mu_q quad "i" quad log sigma^2_q : 512 -> 128$]

			#v(5pt)
			#plain[Enkoder nie zwraca jednej odpowiedzi, lecz #text(weight: "bold")[rozkład]: środek $mu$ i szerokość $sigma$ — jak powiedzenie „$z$ ma wartość $mu$ ± $sigma$". To pozwala modelowi wyrazić niepewność.]

			#v(4pt)
			Domyślnie #text(weight: "bold")[$d_"latent" = 128$].
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 8 — PRZESTRZEŃ LATENTNA I PRIOR
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Przestrzeń latentna i prior warunkowy",
	subtitle: "Przestrzeń latentna to skompresowany opis stanu plazmy; prior wyraża, jakich opisów się spodziewamy.",
)

#grid(
	columns: (0.95fr, 1.05fr),
	gutter: 15pt,
	[
		#card("Posterior q(z | x, c) — opis z danych", fill-color: sage)[
			Enkoder wyznacza rozkład $z$ na podstawie #text(weight: "bold")[rzeczywistych map]:

			#v(3pt)
			#formula[$q_{mu}, q_{log sigma^2} = "Enkoder"(x_"field", c)$]

			Próbka pobierana jest metodą reparametryzacji (różniczkowalny trik):
			#v(3pt)
			#formula[$z = mu + epsilon dot sigma, quad epsilon tilde cal(N)(0, I)$]

			#v(5pt)
			#plain[„Posterior" — co wynika z danych. Enkoder patrzy na prawdziwe mapy i mówi: „$z$ prawdopodobnie jest w tym rejonie przestrzeni latentnej."]
		]

		#v(10pt)

		#card("Po co przestrzeń latentna?", fill-color: amber)[
			- #text(weight: "bold")[Kompresja]: 22 map 2D → 128 liczb.
			- #text(weight: "bold")[Niepewność]: zamiast jednego punktu, model podaje rozkład możliwych stanów.
			- #text(weight: "bold")[Różnorodność]: z tych samych warunków można próbkować wiele fizycznie poprawnych realizacji.

			#v(4pt)
			#plain[To jak encyklopedia skrótów: zamiast całego tomu, 128 liczb opisuje stan plazmy tak jak sygnatura chemiczna opisuje związek.]
		]
	],
	[
		#card("Conditional Prior Network p(z | c) — oczekiwania z warunków", fill-color: teal)[
			Prior to osobna sieć MLP (prosta sieć w pełni połączona), która widzi #emph[tylko] 8 liczb warunków globalnych:

			- Linear: 8 → 128 → 128
			- Dwie głowice: $mu_p$ i $log sigma^2_p$

			#v(5pt)
			Uczy się: „jeśli moc grzewcza wynosi X i pole magnetyczne Y, to $z$ powinno leżeć w tej okolicy przestrzeni latentnej."

			#v(5pt)
			#plain[„Prior" — oczekiwania PRZED zobaczeniem danych. Jak lekarz mówi: „przy tej diagnozie spodziewamy się takich wyników" — zanim zobaczy konkretny przypadek.]
		]

		#v(9pt)

		#insight[Standardowy VAE losuje $z$ z $cal(N)(0,I)$ — szum bez sensu fizycznego. Tu prior jest uczony: losujemy z rozkładu dostosowanego do konkretnych parametrów reaktora, więc każda próbka jest fizycznie sensowna.]

		#v(7pt)

		#card("Jak łączymy prior i posterior?", fill-color: navy)[
			#text(size: 10.8pt)[Model minimalizuje $"KL"(q || p)$ — miarę odległości między rozkładem wyznaczonym z danych a oczekiwanym przez prior. Jeśli są zgodne, $z$ z prioru daje realistyczne mapy w fazie generacji.]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 9 — DEKODER RESIDUALNY
// ══════════════════════════════════════════════════════════

#slide[
#slide-title(
	"Dekoder residualny i rekonstrukcja pól",
	subtitle: "Dekoder przetwarza skompresowany opis z powrotem na 22 pełne mapy fizyczne przy użyciu bloków residualnych.",
)

#grid(
	columns: (1fr, 1fr),
	gutter: 15pt,
	[
		#card("Wejście i rozwinięcie do siatki", fill-color: amber)[
			Dekoder łączy wektor latentny $z$ z warunkami $c$ w jeden wektor wejściowy:

			#v(3pt)
			#formula[$"concat"(z, c) in RR^(128 + 8) = RR^136$]

			Dwie warstwy liniowe „rozwijają" go do przestrzennej siatki:
			- Linear: 136 → 512
			- Linear: 512 → $512 times 13 times 7$ (mała siatka 13×7)

			#v(4pt)
			#plain[To jak narysowanie bardzo małego szkicu (13×7 punktów) z krótkiego opisu tekstowego — szczegóły zostaną dodane w następnych krokach.]
		]

		#v(10pt)

		#card("Stopniowe powiększanie przez dekonwolucje", fill-color: teal)[
			Trzy etapy powiększania (upsampling) z blokami residualnymi:

			- ConvTranspose2d: 512→256 + ResBlock(256)
			- ConvTranspose2d: 256→128 + ResBlock(128)
			- ConvTranspose2d: 128→64 + ResBlock(64)
			- Ostatnia warstwa: Conv2d: 64 → 22

			Na końcu interpolacja biliniowa do dokładnego rozmiaru #text(weight: "bold")[104×50].
		]
	],
	[
		#card("Czym są bloki residualne (ResBlock)?", fill-color: navy)[
			ResBlock oblicza $y = f(x) + x$ — do wyniku dodaje #text(weight: "bold")[oryginalne wejście]:

			#v(4pt)
			#formula[$y = "Conv"("Conv"(x)) + x$]

			#v(4pt)
			#plain[To jak „ścieżka obejścia": gradient może płynąć bezpośrednio przez dodanie $x$, omijając głębokie warstwy. Bez tego, sygnał znika lub eksploduje w wielowarstwowym dekoderze.]

			#v(4pt)
			Bez ResBlock: głęboki dekoder 22 kanałów po wielu dekonwolucjach jest niestabilny numerycznie i trudny w treningu.
		]

		#v(10pt)

		#card("Po co dekoder widzi i $z$ i warunki $c$?", fill-color: amber)[
			#text(size: 10.8pt)[$z$ koduje \"co\" (stan wewnętrzny plazmy), a $c$ koduje \"w jakich warunkach\" (parametry reaktora). Razem pozwalają dekoderowi generować różne mapy dla różnych eksperymentów przy tym samym $z$ — model jest #text(weight: "bold")[elastyczny] i #text(weight: "bold")[warunkowy].]
		]
	],
)
]

// ══════════════════════════════════════════════════════════
// SLAJD 10 — PODSUMOWANIE
// ══════════════════════════════════════════════════════════

#slide[
#slide-title("Najważniejsze cechy architektury")

#v(2pt)

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 11pt,
	card("Lokalne i globalne zależności", fill-color: teal)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		CNN wykrywa lokalne wzorce przestrzenne, Transformer modeluje zależności dalekiego zasięgu. Ich połączenie wystarcza do opisu SOL.
	],
	card("Warunkowanie — generacja na żądanie", fill-color: sage)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		Podając 8 liczb $x_"cond"$, model generuje realistyczne mapy SOL bez SOLPS-ITER. Prior warunkowy gwarantuje fizyczną spójność.
	],
	card("Stabilna rekonstrukcja 22 kanałów", fill-color: amber)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		Bloki residualne umożliwiają trenowanie głębokiego dekodera bez zaniku gradientu — model odtwarza wszystkie 22 pola plazmy.
	],
)

#v(8pt)

#grid(
	columns: (1fr, 1fr),
	gutter: 11pt,
	card("Physics-Informed — fizyka jako ograniczenie", fill-color: navy)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		Trzy człony kary w $L$ (nieujemność, kryterium Bohma, dywergencja strumienia) sprawiają, że sieć nigdy nie generuje fizycznie niemożliwych pól. To kluczowa różnica od zwykłego ML — model „rozumie" prawa fizyki plazmy.
	],
	card("Podsumowanie w jednym zdaniu", fill-color: teal)[
		#set text(size: 9.8pt)
		#set par(leading: 1.0em)
		PI-CVAE to warunkowy autoenkoder wariacyjny: enkoder (CNN + Transformer) streszcza 22 mapy do 128 liczb, prior przewiduje stan z 8 parametrów reaktora, a dekoder residualny odtwarza SOL w milisekundy — milion zapytań w ciągu minut.
	],
)
]
