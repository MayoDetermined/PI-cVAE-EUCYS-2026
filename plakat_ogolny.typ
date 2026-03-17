// ──────────────────────────────────────────────────────────
//  PI-CVAE · Plakat naukowy  —  EUCYS 2026
// ──────────────────────────────────────────────────────────

#set page(
	width: 841mm,   // A0 landscape
	height: 594mm,
	margin: (x: 25mm, top: 25mm, bottom: 20mm),
	fill: rgb("#f7f8fc"),
	background: [
		#place(top + left)[
			#rect(width: 100%, height: 6pt, fill: gradient.linear(rgb("#5b7fa6"), rgb("#6bafcc"), rgb("#7bbf96"), rgb("#d4a46a"), angle: 0deg))
		]
		#place(bottom + left)[
			#rect(width: 100%, height: 4pt, fill: gradient.linear(rgb("#d4a46a"), rgb("#7bbf96"), rgb("#6bafcc"), rgb("#5b7fa6"), angle: 0deg))
		]
	],
)

#set text(font: "Palatino Linotype", fill: rgb("#2c3040"), size: 16pt)
#set par(justify: true, leading: 1.05em)

#show math.equation: set text(font: "Cambria Math", fill: rgb("#4a6a8a"))

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

// ─── Komponenty ──────────────────────────────────────────

#let card(title, fill-color: teal, body) = block(
	width: 100%,
	radius: 12pt,
	clip: true,
	breakable: false,
	fill: soft,
	stroke: (paint: border, thickness: 0.5pt),
	[
		#block(width: 100%, height: 4pt, fill: gradient.linear(fill-color, fill-color.lighten(25%)))
		#pad(left: 18pt, right: 17pt, top: 15pt, bottom: 16pt)[
			#text(size: 17pt, weight: "bold", fill: fill-color)[#title]
			#v(7pt)
			#line(length: 100%, stroke: (paint: rgb("#e8eaf0"), thickness: 0.4pt))
			#v(9pt)
			#block[
				#set text(size: 14pt)
				#set par(leading: 1.05em, justify: true)
				#body
			]
		]
	],
)

#let formula(body) = align(center)[
	#rect(
		inset: (x: 18pt, y: 10pt),
		radius: 9pt,
		fill: gradient.linear(rgb("#eff3fa"), rgb("#f6f8fc"), angle: 90deg),
		stroke: (paint: rgb("#d4dbed"), thickness: 0.5pt),
		[
			#set text(size: 15pt)
			#body
		],
	)
]

#let tag(text-body, fill-color: sage) = rect(
	inset: (x: 12pt, y: 5pt),
	radius: 999pt,
	fill: fill-color.lighten(88%),
	stroke: (paint: fill-color.lighten(30%), thickness: 0.8pt),
	[#text(size: 12pt, weight: "bold", tracking: 0.4pt, fill: fill-color)[#text-body]],
)

#let insight(body) = block(
	width: 100%,
	inset: (left: 16pt, right: 14pt, top: 11pt, bottom: 11pt),
	radius: 9pt,
	breakable: false,
	fill: rgb("#fdf5ea"),
	stroke: (
		left:  (paint: amber, thickness: 3.5pt),
		rest:  (paint: amber.lighten(65%), thickness: 0.35pt),
	),
	[
		#set par(justify: true)
		#text(size: 12pt, fill: amber)[◆] #h(5pt)
		#text(size: 13.5pt, style: "italic", fill: rgb("#8a6530"))[#body]
	],
)

#let plain(body) = block(
	width: 100%,
	inset: (left: 15pt, right: 14pt, top: 10pt, bottom: 11pt),
	radius: 9pt,
	breakable: false,
	fill: rgb("#eef6f2"),
	stroke: (left: (paint: sage, thickness: 3.5pt), rest: (paint: sage.lighten(70%), thickness: 0.35pt)),
	[
		#text(size: 13pt, fill: ink)[#body]
	],
)

#let stage-box(title, subtitle, fill-color) = block(
	width: 100%,
	radius: 10pt,
	clip: true,
	breakable: false,
	stroke: (paint: border, thickness: 0.4pt),
	fill: soft,
	[
		#block(width: 100%, height: 3.5pt, fill: gradient.linear(fill-color, fill-color.lighten(30%)))
		#pad(x: 14pt, bottom: 12pt, top: 10pt)[
			#text(size: 15pt, weight: "bold", fill: ink)[#title]
			#v(5pt)
			#text(size: 12pt, fill: muted, style: "italic")[#subtitle]
		]
	],
)

#let arrow-right() = align(center + horizon)[
	#text(size: 22pt, fill: rgb("#c0c4d0"), baseline: -0.5pt)[⟶]
]

// ══════════════════════════════════════════════════════════
//  NAGŁÓWEK — TYTUŁ PLAKATU
// ══════════════════════════════════════════════════════════

#block(width: 100%, inset: (bottom: 8pt))[
	#grid(
		columns: (1fr, auto),
		gutter: 20pt,
		[
			#text(size: 10pt, tracking: 5pt, fill: subtle, weight: "bold")[EUCYS 2026]
			#v(8pt)
			#text(size: 42pt, weight: "bold", fill: navy)[PI–CVAE: Physics-Informed Conditional \ Variational Autoencoder]
			#v(6pt)
			#text(size: 18pt, fill: muted, style: "italic")[Szybki emulator pól plazmowych SOLPS-ITER oparty na głębokim uczeniu maszynowym]
			#v(10pt)
			#stack(
				dir: ltr,
				spacing: 0pt,
				rect(width: 50mm, height: 3pt, fill: navy, radius: (left: 999pt, right: 0pt)),
				rect(width: 30mm, height: 3pt, fill: teal),
				rect(width: 18mm, height: 3pt, fill: sage),
				rect(width: 22mm, height: 3pt, fill: amber, radius: (left: 0pt, right: 999pt)),
			)
		],
		[
			#align(right + horizon)[
				#block(inset: (top: 15pt))[
					#stack(
						dir: ltr,
						spacing: 10pt,
						tag("CNN + Transformer", fill-color: teal),
						tag("Przestrzeń latentna 128", fill-color: sage),
						tag("Straty fizyczne", fill-color: amber),
					)
				]
			]
		],
	)
]

#v(6pt)
#line(length: 100%, stroke: (paint: border, thickness: 0.5pt))
#v(10pt)

// ══════════════════════════════════════════════════════════
//  SEKCJA 1 — TRZY KOLUMNY GŁÓWNE
// ══════════════════════════════════════════════════════════

#grid(
	columns: (1fr, 1fr, 1fr),
	gutter: 18pt,

	// ── KOLUMNA 1: PROBLEM I MOTYWACJA ──────────────────
	[
		#card("1. Problem i motywacja", fill-color: amber)[
			#text(weight: "bold")[Tokamak] to reaktor fuzji jądrowej, w którym wodór jest podgrzewany do >100 milionów °C i utrzymywany silnym polem magnetycznym. Strefa #text(weight: "bold")[SOL (Scrape-Off Layer)] to cienka warstwa plazmy tuż przy ściance reaktora --- kluczowa dla bezpieczeństwa i wydajności.

			#v(8pt)
			#text(weight: "bold")[SOLPS-ITER] to profesjonalny symulator numeryczny tej strefy. Problem: jedno uruchomienie trwa wiele godzin, a optymalizacja parametrów wymaga tysięcy takich obliczeń.

			#v(8pt)
			#insight[Cel: zastąpić kosztowne symulacje SOLPS-ITER siecią neuronową, która odpowie w milisekundy zamiast godzin.]
		]

		#v(14pt)

		#card("2. Dane wejściowe i wyjściowe", fill-color: teal)[
			Model przyjmuje #text(weight: "bold")[8 parametrów] opisujących warunki eksperymentu (np. moc grzewcza w MW, natężenie pola magnetycznego w T) i generuje #text(weight: "bold")[22 mapy fizyczne] na siatce 104 × 50 punktów:

			#v(6pt)
			- $T_e, T_i$ — temperatura elektronów i jonów
			- $n_a times 10$ — gęstości 10 gatunków jonów
			- $u_a times 10$ — prędkości jonów wzdłuż pola

			#v(6pt)
			#formula[$bold("Wejście:") quad x_"cond" in RR^8 quad arrow.r quad bold("Wyjście:") quad 22 times 104 times 50$]

			#v(6pt)
			#plain[Każda mapa to „termiczny obraz" innej wielkości fizycznej — razem tworzą kompletny opis stanu SOL.]
		]

		#v(14pt)

		#card("3. Normalizacja danych", fill-color: sage)[
			Wartości fizyczne ($T_e, n_a$) rozciągają się na wiele rzędów wielkości. Przed treningiem stosujemy transformację logarytmiczną i standaryzację:

			#v(5pt)
			#formula[$hat(T)_e = (ln(1 + T_e) - mu) / sigma$]

			#v(5pt)
			Prędkości $u_a$ (mogą być ujemne) normalizujemy standardowo: $(u - mu) / sigma$. Warunki $x_"cond"$ również standaryzujemy.

			#v(5pt)
			#plain[Logarytm spłaszcza rozpiętość wartości, normalizacja centruje dane wokół zera — sieć neuronowa uczy się szybciej i stabilniej.]
		]
	],

	// ── KOLUMNA 2: ARCHITEKTURA ─────────────────────────
	[
		#card("4. Architektura PI-CVAE", fill-color: navy)[
			Model składa się z trzech współpracujących modułów:

			#v(8pt)
			#grid(
				columns: (1fr,),
				gutter: 8pt,
				stage-box("Enkoder (CNN + Transformer)", [22 mapy → cechy lokalne → cechy globalne → wektor 512D → $mu_q, log sigma^2_q$ (po 128)], teal),
				stage-box("Prior Network (MLP)", [$x_"cond"$ (8 liczb) → MLP 128→128 → $mu_p, log sigma^2_p$ (po 128)], sage),
				stage-box("Dekoder residualny", [$"concat"(z, c) in RR^136$ → FC → siatka 13×7 → 3× dekonwolucja + ResBlock → 22 map], amber),
			)

			#v(7pt)
			#insight[Trening: enkoder + dekoder uczą się razem. Generacja: pomijamy enkoder, próbkujemy $z$ z prioru i dekodujemy.]
		]

		#v(14pt)

		#card("5. Enkoder hybrydowy", fill-color: teal)[
			#text(weight: "bold")[CNN] — 4 warstwy splotowe (22→64→128→256→512 kanałów, stride 2) z GroupNorm i ReLU. Wyciąga lokalne cechy przestrzenne.

			#v(6pt)
			#text(weight: "bold")[Transformer] — mapy ze 512 kanałów rozkładane w sekwencję tokenów. 2 warstwy z self-attention (4 głowice) modelują zależności globalnego zasięgu.

			#v(6pt)
			#formula[$512 times H times W arrow.r (H dot W) times 512 arrow.r^"Transformer" 512 arrow.r mu_q, log sigma^2_q in RR^128$]

			#v(6pt)
			#plain[CNN widzi drzewo, Transformer widzi las — łącznie enkoder rozumie zarówno lokalne struktury SOL, jak i spójność globalną.]
		]

		#v(14pt)

		#card("6. Przestrzeń latentna i prior", fill-color: sage)[
			Enkoder nie zwraca jednego punktu, lecz #text(weight: "bold")[rozkład]: $q(z | x, c) = cal(N)(mu_q, sigma_q^2)$.

			#v(5pt)
			#text(weight: "bold")[Reparametryzacja:]
			#formula[$z = mu + epsilon dot sigma, quad epsilon tilde cal(N)(0, I), quad z in RR^128$]

			#v(5pt)
			#text(weight: "bold")[Prior warunkowy:] osobna sieć MLP widzi tylko 8 liczb warunków i przewiduje $p(z|c)$. Model minimalizuje KL($q || p$), by oba rozkłady się zgadzały.

			#v(5pt)
			#insight[Standardowy VAE losuje $z$ z $cal(N)(0, I)$. Tu prior jest uczony — losujemy z rozkładu dopasowanego do parametrów reaktora.]
		]
	],

	// ── KOLUMNA 3: TRENING I WYNIKI ─────────────────────
	[
		#card("7. Fizyka jako ograniczenie — 3 kary", fill-color: amber)[
			#grid(
				columns: (1fr,),
				gutter: 10pt,
				[
					#text(weight: "bold", fill: teal)[I. Nieujemność] — $T_e, T_i, n_a >= 0$ \
					Temperatura i gęstość nie mogą być ujemne.
				],
				[
					#text(weight: "bold", fill: sage)[II. Kryterium Bohma] — $|u_a| <= c_s = sqrt((T_e + T_i)/m)$ \
					Prędkość jonów nie może przekraczać prędkości dźwięku w plazmie.
				],
				[
					#text(weight: "bold", fill: amber)[III. Zachowanie strumienia] — $nabla dot (n_a u_a) approx 0$ \
					Strumień cząstek nie może mieć źródeł ani ujść wewnątrz domeny. Dywergencja obliczana różnicami centralnymi.
				],
			)

			#v(6pt)
			#plain[Te trzy kary gwarantują, że sieć nigdy nie wygeneruje fizycznie niemożliwych pól — kluczowa różnica od zwykłego ML.]
		]

		#v(14pt)

		#card("8. Funkcja straty i trening", fill-color: navy)[
			#formula[$L = underbrace(L_"rec", "MSE") + beta_"KL" dot underbrace("KL"(q || p), "spójność") + w_1 underbrace(L_"nonneg", "fizyka") + w_2 underbrace(L_"Bohm", "fizyka") + w_3 underbrace(L_"div", "fizyka")$]

			#v(7pt)
			#grid(
				columns: (1fr, 1fr),
				gutter: 12pt,
				[
					- Optymalizator: Adam ($"lr" = 2 times 10^(-4)$)
					- Batch: 128, epoki: do 500
					- Gradient clipping: 5.0
					- ReduceLROnPlateau + early stopping
				],
				[
					- KL annealing: $beta$ rośnie 0→1 przez 100 epok
					- Wagi kar: $w_1 = 10^(-3)$, $w_2 = 5 dot 10^(-4)$, $w_3 = 3 dot 10^(-3)$
					- Mixed precision (AMP) na GPU
				],
			)
		]

		#v(14pt)

		#card("9. Dekoder residualny", fill-color: teal)[
			$z$ i $c$ konkatenowane do $RR^136$, rozwijane FC do siatki $512 times 13 times 7$, potem 3 etapy dekonwolucji z blokami residualnymi:

			#v(5pt)
			#formula[$y = "Conv"("Conv"(x)) + x$]

			#v(5pt)
			ConvTranspose: 512→256→128→64 + ResBlock na każdym etapie. Ostatnia warstwa Conv2d: 64→22. Interpolacja biliniowa do 104×50.

			#v(5pt)
			#plain[Bloki residualne zapobiegają zanikowi gradientu — dekoder stabilnie odtwarza wszystkie 22 kanały fizyczne.]
		]
	],
)

#v(14pt)

// ══════════════════════════════════════════════════════════
//  SEKCJA DOLNA — PODSUMOWANIE
// ══════════════════════════════════════════════════════════

#block(
	width: 100%,
	radius: 14pt,
	clip: true,
	fill: rgb("#3d5a7a"),
	stroke: none,
	[
		#block(width: 100%, height: 4pt, fill: gradient.linear(teal, sage, amber, angle: 0deg))
		#pad(x: 28pt, top: 18pt, bottom: 20pt)[
			#grid(
				columns: (1fr, 1fr, 1fr, 1fr),
				gutter: 20pt,
				[
					#text(size: 13pt, weight: "bold", fill: teal)[Lokalne + globalne cechy]
					#v(5pt)
					#text(size: 12.5pt, fill: rgb("#d0dce8"))[CNN wykrywa wzorce przestrzenne, Transformer łączy odległe regiony SOL w jedno spójne streszczenie.]
				],
				[
					#text(size: 13pt, weight: "bold", fill: sage)[Warunkowa generacja]
					#v(5pt)
					#text(size: 12.5pt, fill: rgb("#d0dce8"))[Podając 8 parametrów reaktora, model generuje realistyczne mapy SOL bez uruchamiania SOLPS-ITER.]
				],
				[
					#text(size: 13pt, weight: "bold", fill: amber)[Fizyka wbudowana w model]
					#v(5pt)
					#text(size: 12.5pt, fill: rgb("#d0dce8"))[Trzy kary fizyczne (nieujemność, Bohm, dywergencja) eliminują niefizyczne wyniki z przestrzeni rozwiązań.]
				],
				[
					#text(size: 13pt, weight: "bold", fill: white)[Kluczowy wynik]
					#v(5pt)
					#text(size: 12.5pt, fill: rgb("#d0dce8"))[PI-CVAE zastępuje godziny symulacji SOLPS-ITER odpowiedzią w milisekundy — umożliwiając masową optymalizację parametrów reaktora.]
				],
			)
		]
	],
)
