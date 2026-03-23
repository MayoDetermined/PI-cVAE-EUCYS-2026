// ──────────────────────────────────────────────────────────
//  PI-CVAE · Plakat naukowy  —  EUCYS 2026
//  Wersja ulepszona: lepsza typografia, poprawione diagramy,
//  precyzyjniejszy tekst naukowy
// ──────────────────────────────────────────────────────────

#set page(
  width:  841mm,   // A0 landscape
  height: 594mm,
  margin: (x: 1mm, top: 1mm, bottom: 1mm),
  fill: rgb("#f5f6fb"),
  background: [
    #place(top + left)[
      #rect(width: 100%, height: 5.5pt,
        fill: gradient.linear(rgb("#5b7fa6"), rgb("#6bafcc"), rgb("#7bbf96"), rgb("#d4a46a"), angle: 0deg))
    ]
    #place(bottom + left)[
      #rect(width: 100%, height: 3.5pt,
        fill: gradient.linear(rgb("#d4a46a"), rgb("#7bbf96"), rgb("#6bafcc"), rgb("#5b7fa6"), angle: 0deg))
    ]
  ],
)

#set text(font: "Palatino Linotype", fill: rgb("#22283a"), size: 14.5pt)
#set par(justify: true, leading: 1.03em)
#show math.equation: set text(font: "Cambria Math", fill: rgb("#3d5f8a"))

// ─── Paleta kolorów ─────────────────────────────────────
#let navy   = rgb("#5b7fa6")
#let teal   = rgb("#6bafcc")
#let amber  = rgb("#d4a46a")
#let sage   = rgb("#7bbf96")
#let violet = rgb("#8a6bc9")
#let ink    = rgb("#22283a")
#let muted  = rgb("#5e6578")
#let subtle = rgb("#9aa0b0")
#let border = rgb("#dde0eb")
#let soft   = white

// ─── Komponenty ─────────────────────────────────────────

#let card(title, fill-color: teal, body) = block(
  width: 100%, radius: 9pt, clip: true, breakable: false,
  fill: soft, stroke: (paint: border, thickness: 0.5pt),
  [
    #block(width: 100%, height: 2.5pt,
      fill: gradient.linear(fill-color, fill-color.lighten(30%)))
    #pad(left: 9pt, right: 9pt, top: 6pt, bottom: 7pt)[
      #text(size: 16.5pt, weight: "bold", fill: fill-color)[#title]
      #v(5pt)
      #line(length: 100%, stroke: (paint: rgb("#e6e8f2"), thickness: 0.7pt))
      #v(6pt)
      #block[
        #set text(size: 13pt)
        #set par(leading: 0.88em, justify: true)
        #body
      ]
    ]
  ],
)

#let formula(body) = align(center)[
  #rect(
    inset: (x: 10pt, y: 5pt), radius: 6pt,
    fill: gradient.linear(rgb("#edf1fa"), rgb("#f5f7fc"), angle: 90deg),
    stroke: (paint: rgb("#ccd3e8"), thickness: 0.5pt),
    [#set text(size: 11.5pt); #body],
  )
]

#let tag(text-body, fill-color: sage) = rect(
  inset: (x: 7pt, y: 2.5pt), radius: 999pt,
  fill: fill-color.lighten(88%),
  stroke: (paint: fill-color.lighten(30%), thickness: 0.7pt),
  [#text(size: 9.5pt, weight: "bold", tracking: 0.4pt, fill: fill-color)[#text-body]],
)

#let insight(body) = block(
  width: 100%, inset: (left: 10pt, right: 9pt, top: 6pt, bottom: 6pt),
  radius: 6pt, breakable: false, fill: rgb("#fdf6ea"),
  stroke: (left: (paint: amber, thickness: 2.5pt), rest: (paint: amber.lighten(68%), thickness: 0.3pt)),
  [
    #text(size: 9.5pt, fill: amber)[◆] #h(3pt)
    #text(size: 10.5pt, style: "italic", fill: rgb("#7a5a28"))[#body]
  ],
)

#let plain(body) = block(
  width: 100%, inset: (left: 10pt, right: 9pt, top: 5pt, bottom: 6pt),
  radius: 6pt, breakable: false, fill: rgb("#eef6f1"),
  stroke: (left: (paint: sage, thickness: 2.5pt), rest: (paint: sage.lighten(72%), thickness: 0.3pt)),
  [#text(size: 10pt, fill: ink)[#body]],
)

#let violet-note(body) = block(
  width: 100%, inset: (left: 10pt, right: 9pt, top: 5pt, bottom: 6pt),
  radius: 6pt, breakable: false, fill: rgb("#f2effe"),
  stroke: (left: (paint: violet, thickness: 2.5pt), rest: (paint: violet.lighten(68%), thickness: 0.3pt)),
  [#text(size: 10pt, fill: rgb("#4a3580"))[#body]],
)

#let stage-box(title, subtitle, fill-color) = block(
  width: 100%, radius: 6pt, clip: true, breakable: false,
  stroke: (paint: border, thickness: 0.4pt), fill: soft,
  [
    #block(width: 100%, height: 2pt, fill: gradient.linear(fill-color, fill-color.lighten(35%)))
    #pad(x: 9pt, bottom: 6pt, top: 5pt)[
      #text(size: 11pt, weight: "bold", fill: ink)[#title]
      #v(2pt)
      #text(size: 8.5pt, fill: muted, style: "italic")[#subtitle]
    ]
  ],
)

// ─── Schemat tokamaka (SOL) ──────────────────────────────
#let tokamak-schema() = align(center)[
  #block(width: 195pt, height: 70pt, clip: false)[
    // Pierwsza ściana reaktora
    #place(center + horizon)[
      #rect(width: 195pt, height: 64pt, radius: 999pt,
        fill: rgb("#d8ddf0"), stroke: (paint: rgb("#6677aa"), thickness: 1.3pt))
    ]
    // Strefa SOL (separatryks)
    #place(center + horizon)[
      #rect(width: 152pt, height: 48pt, radius: 999pt,
        fill: amber.lighten(80%), stroke: (paint: amber, thickness: 1.6pt))
    ]
    // Rdzeń plazmy
    #place(center + horizon)[
      #rect(width: 106pt, height: 30pt, radius: 999pt,
        fill: navy.lighten(30%), stroke: (paint: navy.lighten(10%), thickness: 0.8pt))
    ]
    // Etykieta: rdzeń
    #place(center + horizon)[
      #text(size: 7pt, weight: "bold", fill: white)[Rdzeń  >100 M°C]
    ]
    // Etykieta: SOL
    #place(right + horizon, dx: -16pt)[
      #text(size: 7pt, weight: "bold", fill: amber.darken(40%))[SOL]
    ]
    // Etykieta: pierwsza ściana
    #place(right + top, dx: -2pt, dy: 3pt)[
      #text(size: 6pt, fill: rgb("#6677aa"))[1. ściana]
    ]
    // Dywertor
    #place(center + bottom)[
      #text(size: 6.5pt, fill: navy.lighten(15%), weight: "bold")[▼ dywertor]
    ]
    // Strumień ciepła → dywertor
    #place(center + horizon, dy: 15pt)[
      #text(size: 9pt, fill: amber.darken(10%), weight: "bold")[↓]
    ]
    // Separatryks label
    #place(left + horizon, dx: 26pt)[
      #text(size: 6pt, fill: amber.darken(25%), style: "italic")[sep.]
    ]
    // Strzałka pola B
    #place(left + horizon, dx: 6pt)[
      #text(size: 6.5pt, fill: navy.lighten(10%), weight: "bold")[B]
      #text(size: 5.5pt, fill: navy.lighten(10%))[→]
    ]
  ]
  #v(2pt)
  #grid(columns: (auto, auto, auto), gutter: 10pt, align: center + horizon,
    [#rect(width: 8pt, height: 8pt, radius: 2pt, fill: navy.lighten(30%), stroke: none)
     #h(2pt) #text(size: 7pt, fill: muted)[Rdzeń]],
    [#rect(width: 8pt, height: 8pt, radius: 2pt, fill: amber.lighten(80%),
       stroke: (paint: amber, thickness: 0.7pt))
     #h(2pt) #text(size: 7pt, fill: muted)[SOL ← symulacja]],
    [#rect(width: 8pt, height: 8pt, radius: 2pt, fill: rgb("#d8ddf0"),
       stroke: (paint: rgb("#6677aa"), thickness: 0.7pt))
     #h(2pt) #text(size: 7pt, fill: muted)[Pierwsza ściana]],
  )
]

// ─── Diagram I/O ─────────────────────────────────────────
#let io-diagram() = {
  let fb(col, body) = block(
    width: 100%, inset: (x: 6pt, y: 4.5pt), radius: 5pt,
    fill: col.lighten(86%), stroke: (paint: col, thickness: 0.9pt),
    [#set text(size: 8pt, weight: "bold", fill: col.darken(25%))
     #align(center)[#body]]
  )
  let arr = align(center + horizon)[
    #text(size: 14pt, fill: muted)[→]
  ]
  grid(
    columns: (1fr, auto, 1.4fr, auto, 1fr),
    gutter: 4pt, align: center + horizon,
    fb(sage)[
      $bold(x)_"cond" in RR^8$ \
      #set text(size: 7pt, weight: "regular")
      #set par(leading: 0.75em)
      Moc grzewcza, pole B, \ gęstość linii pola, …
    ],
    arr,
    fb(navy)[
      #text(size: 9pt)[PI-CVAE] \
      #set text(size: 7pt, weight: "regular")
      #set par(leading: 0.75em)
      Prior MLP · Enkoder \ CNN+Transf. · Dekoder Res
    ],
    arr,
    fb(teal)[
      $bold(x)_"rec" in RR^(22 times 104 times 50)$ \
      #set text(size: 7pt, weight: "regular")
      #set par(leading: 0.75em)
      $T_e, T_i, n_a (times 10), u_a (times 10)$
    ],
  )
}

// ─── Diagram architektury ────────────────────────────────
#let arch-flow-diagram() = {
  let fb-prior(body) = block(
    width: 100%, inset: (x: 4pt, y: 3pt), radius: 4pt,
    fill: sage.lighten(87%), stroke: (paint: sage, thickness: 0.85pt),
    [#set text(size: 6.5pt, weight: "bold", fill: sage.darken(25%))
     #align(center)[#body]]
  )
  let fb-enc(body) = block(
    width: 100%, inset: (x: 4pt, y: 3pt), radius: 4pt,
    fill: teal.lighten(87%), stroke: (paint: teal, thickness: 0.85pt),
    [#set text(size: 6.5pt, weight: "bold", fill: teal.darken(25%))
     #align(center)[#body]]
  )
  let fb-dec(body) = block(
    width: 100%, inset: (x: 4pt, y: 3pt), radius: 4pt,
    fill: amber.lighten(87%), stroke: (paint: amber, thickness: 0.85pt),
    [#set text(size: 6.5pt, weight: "bold", fill: amber.darken(25%))
     #align(center)[#body]]
  )
  let arr = align(center + horizon)[#text(size: 12pt, fill: muted)[→]]

  stack(spacing: 2.5pt,
    // Prior — generacja
    block(width: 100%, radius: 5pt,
      fill: sage.lighten(95%), stroke: (paint: sage.lighten(42%), thickness: 0.55pt),
      inset: (x: 5pt, y: 3.5pt))[
      #text(size: 5.5pt, weight: "bold", fill: sage, tracking: 0.8pt)[▸ PRIOR — generacja (inference)]
      #v(2pt)
      #grid(columns: (auto, auto, auto, auto, auto), gutter: 3pt, align: center + horizon,
        fb-prior[$bold(c)$ 8 param], arr,
        fb-prior[MLP \ 128→128], arr,
        fb-prior[$mu_p, sigma_p$ \ $p(z|c)$],
      )
    ],
    // Separator KL
    align(center)[
      #rect(inset: (x: 10pt, y: 6pt), radius: 4pt, height: 28pt,
        fill: rgb("#eeebfa"), stroke: (paint: violet, thickness: 0.8pt))[
        #align(center + horizon)[
          #text(size: 6pt, weight: "bold", fill: violet.darken(15%))[
            $cal(L)_"KL" = "KL"(q(z|x,c) , \|\| , p(z|c))$
          ]
        ]
        #v(1pt)
        #align(center + horizon)[
          #text(size: 5.5pt, fill: violet.darken(15%))[
            minimalizowane podczas treningu
          ]
        ]
      ]
    ],
    // Enkoder + Dekoder — trening
    block(width: 100%, radius: 5pt,
      fill: teal.lighten(95%), stroke: (paint: teal.lighten(42%), thickness: 0.55pt),
      inset: (x: 5pt, y: 3.5pt))[
      #text(size: 5.5pt, weight: "bold", fill: teal, tracking: 0.8pt)[▸ ENKODER + DEKODER — trening]
      #v(2pt)
      #grid(columns: (1fr, auto, 1.1fr, auto, 1fr, auto, 1fr), gutter: 3pt, align: center + horizon,
        fb-enc[22 mapy \ 104×50], arr,
        fb-enc[CNN 4L \ + Transf.], arr,
        fb-enc[$mu_q, sigma_q$ \ sample $z$], arr,
        fb-dec[Dekoder Res \ → 22 mapy],
      )
    ],
  )
}

// ─── Wizualizacja CNN enkodera ───────────────────────────
#let cnn-encoder-viz() = {
  let H = 62pt
  let layer(top-lbl, btm-lbl, rw, rh, col) = box(height: H, width: rw + 10pt)[
    #align(bottom + center)[
      #stack(dir: ttb, spacing: 1.5pt,
        text(size: 5pt, weight: "bold", fill: col.darken(22%))[#top-lbl],
        rect(width: rw, height: rh, radius: 2pt,
          fill: col.lighten(68%), stroke: (paint: col, thickness: 0.85pt)),
        text(size: 4.5pt, fill: muted)[#btm-lbl],
      )
    ]
  ]
  let arr = box(height: H, width: 11pt)[
    #align(bottom + center)[#pad(bottom: 19pt)[#text(size: 9pt, fill: muted)[→]]]
  ]
  align(center)[
    #stack(dir: ltr, spacing: 0pt,
      layer([Input], [22ch \ 104×50], 22pt, 20pt, sage),
      arr,
      layer([Conv1 \ GN+ReLU], [64ch \ 52×25], 19pt, 26pt, teal.lighten(12%)),
      arr,
      layer([Conv2 \ GN+ReLU], [128ch \ 26×13], 15pt, 32pt, teal),
      arr,
      layer([Conv3 \ GN+ReLU], [256ch \ 13×7], 11pt, 39pt, teal.darken(12%)),
      arr,
      layer([Conv4 \ GN+ReLU], [512ch \ 7×4], 9pt, 44pt, navy),
      arr,
      layer([Transf. \ 2L 4H \ 512D], [global \ kontekst], 19pt, 38pt, navy.darken(12%)),
      arr,
      layer([$mu_q, sigma_q$], [$z in RR^128$], 18pt, 30pt, violet),
    )
  ]
}

// ─── Wizualizacja przestrzeni latentnej ──────────────────
#let latent-viz() = align(center)[
  #block(width: 205pt, height: 56pt, clip: false)[
    // Prior p(z|c)
    #place(left + horizon)[
      #rect(width: 100pt, height: 46pt, radius: 999pt,
        fill: sage.lighten(82%), stroke: (paint: sage, thickness: 1.2pt))
    ]
    // Posterior q(z|x,c)
    #place(right + horizon)[
      #rect(width: 100pt, height: 46pt, radius: 999pt,
        fill: teal.lighten(77%), stroke: (paint: teal, thickness: 1.2pt))
    ]
    // Przecięcie
    #place(center + horizon)[
      #rect(width: 26pt, height: 36pt, radius: 999pt,
        fill: rgb("#d0eee0").transparentize(20%), stroke: none)
    ]
    // Strzałka KL (q → p)
    #place(center + horizon, dy: -8pt)[
      #text(size: 9pt, fill: violet, weight: "bold")[←]
    ]
    #place(center + horizon, dy: -17pt)[
      #text(size: 5.5pt, fill: violet.darken(15%), weight: "bold")[min KL]
    ]
    // Label prior
    #place(left + horizon, dx: 5pt)[
      #text(size: 6pt, weight: "bold", fill: sage.darken(30%))[p(z|c) \ #text(weight: "regular", style: "italic")[prior \ (MLP)]]
    ]
    // Label posterior
    #place(right + horizon, dx: -57pt)[
      #text(size: 6pt, weight: "bold", fill: teal.darken(30%))[q(z|x,c) \ #text(weight: "regular", style: "italic")[posterior \ (Enkoder)]]
    ]
    // Label obszar wspólny
    #place(center + horizon, dy: 9pt)[
      #text(size: 5pt, fill: violet, style: "italic")[zbliżanie]
    ]
  ]
  #v(2pt)
  #text(size: 6pt, fill: muted, style: "italic")[Minimalizacja KL zbliża posterior (Enkoder) do prioru (MLP) — po treningu generujemy z p(z|c)]
]

// ─── Blok residualny ─────────────────────────────────────
#let resblock-viz() = {
  let mb(lbl, col) = rect(width: 56pt, height: 19pt, radius: 3pt,
    fill: col.lighten(82%), stroke: (paint: col, thickness: 0.75pt),
    [#align(center + horizon)[#set text(size: 5pt, weight: "bold", fill: col.darken(28%)); #lbl]])
  let arw = align(center + horizon)[#text(size: 8pt, fill: muted)[→]]
  stack(dir: ttb, spacing: 0pt,
    rect(width: 100%, inset: (x: 9pt, top: 3.5pt, bottom: 3.5pt),
      radius: (top-left: 6pt, top-right: 6pt),
      fill: amber.lighten(92%),
      stroke: (top: (paint: amber, thickness: 0.85pt),
               left: (paint: amber, thickness: 0.85pt),
               right: (paint: amber, thickness: 0.85pt),
               bottom: none),
      [#align(center)[#text(size: 5.5pt, fill: amber.darken(38%), style: "italic")[
        skip connection: x dodawane bezpośrednio do wyjścia (tożsamość)
      ]]]
    ),
    rect(width: 100%, inset: (x: 6pt, y: 5pt),
      radius: (bottom-left: 6pt, bottom-right: 6pt),
      fill: none,
      stroke: (bottom: (paint: amber, thickness: 0.85pt),
               left: (paint: amber, thickness: 0.85pt),
               right: (paint: amber, thickness: 0.85pt),
               top: none),
      [#align(center + horizon)[
        #stack(dir: ltr, spacing: 2pt,
          align(horizon)[#text(size: 7pt, fill: muted)[x →]],
          mb([Conv2d 3×3 \ GN + ReLU], teal),
          arw,
          mb([Conv2d 3×3 \ GroupNorm], teal.darken(12%)),
          arw,
          rect(width: 18pt, height: 18pt, radius: 999pt,
            fill: amber.lighten(77%), stroke: (paint: amber, thickness: 0.9pt),
            [#align(center + horizon)[#text(size: 11pt, weight: "bold", fill: amber.darken(22%))[+]]]
          ),
          align(horizon)[#text(size: 7pt, fill: muted)[→ y]],
        )
      ]]
    ),
  )
}

// ─── Kary fizyczne — trzy ikony ──────────────────────────
#let physics-badges() = {
  let badge(icon, label, col) = block(
    inset: (x: 8pt, y: 5pt), radius: 7pt,
    fill: col.lighten(88%), stroke: (paint: col, thickness: 0.7pt),
    [#align(center)[
      #text(size: 14pt, fill: col.darken(10%))[#icon]
      #v(1.5pt)
      #text(size: 7pt, weight: "bold", fill: col.darken(25%))[#label]
    ]]
  )
  grid(columns: (1fr, 1fr, 1fr), gutter: 6pt,
    badge("🧊", "Nieujemność\n$T_e, T_i, n_a ≥ 0$", teal),
    badge("⚡", "Kryterium Bohma\n$|u_a| ≤ c_s$", sage),
    badge("🔄", "Zachowanie\nstrumienia", amber),
  )
}

// ══════════════════════════════════════════════════════════
//  NAGŁÓWEK
// ══════════════════════════════════════════════════════════

#block(width: 100%, inset: (bottom: 4pt))[
  #grid(columns: (1fr, auto), gutter: 14pt,
    [
      #text(size: 8.5pt, tracking: 5pt, fill: subtle, weight: "bold")[EUCYS 2026 · PLAKAT NAUKOWY]
      #v(3pt)
      #text(size: 50pt, weight: "bold", fill: navy, tracking: -0.3pt)[PI–CVAE: Physics-Informed Conditional Variational Autoencoder]
      #v(4pt)
      #text(size: 22pt, fill: muted, style: "italic")[Głęboki emulator pól plazmowych strefy SOL dla tokamaka — generacja w milisekundy zamiast godzin symulacji SOLPS-ITER]
      #v(5pt)
      #stack(dir: ltr, spacing: 0pt,
        rect(width: 48mm, height: 2.5pt, fill: navy, radius: (left: 999pt, right: 0pt)),
        rect(width: 28mm, height: 2.5pt, fill: teal),
        rect(width: 16mm, height: 2.5pt, fill: sage),
        rect(width: 20mm, height: 2.5pt, fill: amber, radius: (left: 0pt, right: 999pt)),
      )
    ],
    [
      #align(right + bottom)[
        #block(inset: (top: 8pt))[
          #stack(dir: ltr, spacing: 7pt,
            tag("Głębokie uczenie", fill-color: teal),
            tag("Emulator fizyczny", fill-color: sage),
            tag("Physics-Informed AI", fill-color: amber),
          )
        ]
      ]
    ],
  )
]

#v(2.5pt)
#line(length: 100%, stroke: (paint: border, thickness: 0.5pt))
#v(4.5pt)

// ══════════════════════════════════════════════════════════
//  TRZY KOLUMNY
// ══════════════════════════════════════════════════════════

#grid(columns: (1fr, 1fr, 1fr), gutter: 5pt, align: top,

// ══ KOLUMNA 1 ════════════════════════════════════════════
[
  #card("1. Problem i motywacja", fill-color: amber)[
    Fuzja termojądrowa jest potencjalnie #text(weight: "bold")[nieograniczonym, bezemisyjnym źródłem energii]. #text(weight: "bold")[Tokamak] (np. ITER) utrzymuje plazmę w temperaturze przekraczającej #text(weight: "bold")[100 mln °C] silnym polem magnetycznym.

    #v(2pt)
    #tokamak-schema()
    #v(2pt)

    Strefa #text(weight: "bold")[SOL (Scrape-Off Layer)] — obszar między rdzeniem plazmy a pierwszą ścianą — decyduje o trwałości reaktora. Kod #text(weight: "bold")[SOLPS-ITER] symuluje SOL z dużą dokładnością, lecz #text(weight: "bold")[jedno uruchomienie trwa wiele godzin]. Optymalizacja wymagałaby #text(weight: "bold")[dziesiątek tysięcy] takich biegów.

    #v(2pt)
    #insight[Cel: sieć neuronowa zastępująca SOLPS-ITER, generująca kompletny stan SOL w ~1 ms, przy zachowaniu praw fizyki.]
  ]

  #v(4pt)

  #card("2. Dane wejściowe i wyjściowe", fill-color: teal)[
    #io-diagram()
    #v(3pt)

    Model przyjmuje #text(weight: "bold")[8 parametrów eksperymentu] i generuje #text(weight: "bold")[22 mapy 2D (104×50 siatek)]:

    #v(2pt)
    #grid(columns: (1fr, 1fr), gutter: 5pt,
      [• $T_e, T_i$ — temperatura e⁻ i jonów \ • $n_a times 10$ — gęstości 10 gatunków],
      [• $u_a times 10$ — prędkości jonów wzdłuż $bold(B)$ \ • łącznie: 22 × 104 × 50 = #text(weight: "bold")[114 400 wartości]],
    )

    #v(2pt)
    #plain[Każda mapa to fizyczny „przekrój" innej wielkości przez strefę SOL — razem tworzą pełny opis stanu plazmy.]
  ]

  #v(4pt)

  #card("3. Normalizacja danych", fill-color: sage)[
    Wartości ($T_e, n_a$) obejmują wiele rzędów wielkości (np. $10^{18}$–$10^{22}$ m⁻³). Stosujemy *log-normalizację*:

    #v(2pt)
    #formula[$hat(T)_e = (ln(1 + T_e) - mu_"log") / sigma_"log"$]

    #v(2pt)
    Prędkości $u_a$ (znak ± zachowany) standaryzujemy zwykłą z-normalizacją: $(u - mu) / sigma$. Warunki $bold(x)_"cond"$ również standaryzujemy osobno.

    #v(3pt)
    #align(center + horizon)[
      #stack(dir: ltr, spacing: 6pt)[
        #rect(width: 46pt, height: 28pt, radius: 6pt,
          fill: sage.lighten(82%), stroke: (paint: sage, thickness: 0.9pt))[
          #align(center + horizon)[#text(size: 7.25pt, weight: "bold", fill: sage.darken(22%))[Dane surowe]]
        ]
        #text(size: 12pt, fill: muted)[→]
        #rect(width: 72pt, height: 28pt, radius: 6pt,
          fill: teal.lighten(82%), stroke: (paint: teal, thickness: 0.9pt))[
          #align(center + horizon)[#text(size: 7pt, weight: "bold", fill: teal.darken(22%))[$ln(1+x)$ + z-norm.]]
        ]
        #text(size: 12pt, fill: muted)[→]
        #rect(width: 46pt, height: 28pt, radius: 6pt,
          fill: amber.lighten(82%), stroke: (paint: amber, thickness: 0.9pt))[
          #align(center + horizon)[#text(size: 7.25pt, weight: "bold", fill: amber.darken(22%))[Dane norm.]]
        ]
      ]
    ]
    #v(2pt)
    #plain[Log-transform spłaszcza rozpiętość wartości; normalizacja centruje rozkład — sieć uczy się stabilniej i szybciej.]
  ]
],

// ══ KOLUMNA 2 ════════════════════════════════════════════
[
  #card("4. Architektura PI-CVAE", fill-color: navy)[
    Model składa się z trzech modułów działających wspólnie:

    #v(3pt)
    #arch-flow-diagram()

    #v(3pt)
    #grid(columns: (1fr,), gutter: 3.5pt,
      stage-box(
        "Enkoder hybrydowy (CNN + Transformer)",
        "22 mapy 104×50 → CNN 4L → Transformer 2L → μ_q, σ_q ∈ ℝ¹²⁸",
        teal,
      ),
      stage-box(
        "Prior warunkowy (MLP)",
        "8 param. → MLP [128→128→128] → μ_p, σ_p — uczony, nie N(0,I)",
        sage,
      ),
      stage-box(
        "Dekoder residualny (ConvTranspose + ResBlock)",
        "concat(z, c) ∈ ℝ¹³⁶ → FC → 13×7 → 3× upsampling → 22 mapy 104×50",
        amber,
      ),
    )

    #v(2pt)
    #insight[Inference: pomijamy enkoder; próbkujemy $z tilde p(z|c)$ z prioru i dekodujemy — brak potrzeby danych x.]
  ]

  #v(4pt)

  #card("5. Enkoder hybrydowy CNN + Transformer", fill-color: teal)[
    #cnn-encoder-viz()
    #v(2.5pt)

    #grid(columns: (1fr, 1fr), gutter: 6pt,
      [#text(weight: "bold")[CNN (4 warstwy)] — splot 3×3, GroupNorm, ReLU, stride 2. Każda warstwa redukuje przestrzeń 2× i podwaja kanały. Wydobywa *lokalne wzorce* pola.],
      [#text(weight: "bold")[Transformer (2L, 4H)] — cechy 512D tokenizowane i przekształcane self-attention. Modeluje *globalne zależności* struktury SOL.]
    )

    #v(2pt)
    #plain[CNN + Transformer: lokalna precyzja + globalny kontekst → kompletne, spójne streszczenie pola w 128-wymiarowej przestrzeni latentnej.]
  ]

  #v(4pt)

  #card("6. Przestrzeń latentna i prior warunkowy", fill-color: sage)[
    Enkoder nie zwraca punktu, lecz *rozkład Gaussa*:

    #v(1.5pt)
    #formula[$z = mu_q + epsilon dot sigma_q, quad epsilon tilde cal(N)(0, bold(I)), quad z in RR^128$]
    #v(1.5pt)

    #latent-viz()
    #v(1.5pt)

    #text(weight: "bold")[Prior warunkowy:] MLP przewiduje $p(z|c) = cal(N)(mu_p(c), sigma_p^2(c))$ z 8 parametrów. Trening minimalizuje $"KL"(q || p)$, zbliżając posterior do prioru.

    #v(2pt)
    #violet-note[Kluczowa różnica względem standardowego VAE: prior jest *uczony* — model wie, jaki rozkład latentny jest właściwy dla danych parametrów reaktora.]
  ]
],

// ══ KOLUMNA 3 ════════════════════════════════════════════
[
  #card("7. Wbudowane ograniczenia fizyczne", fill-color: amber)[
    PI-CVAE kara sieć za naruszenie praw fizyki podczas treningu:

    #v(3pt)
    #physics-badges()
    #v(3pt)

    #grid(columns: (auto, 1fr), gutter: 5pt, row-gutter: 4pt,
      text(weight: "bold", fill: teal.darken(15%))[I.],
      [*Nieujemność* ($T_e, T_i, n_a \ge 0$): temperatura i gęstość nie mogą być ujemne. Kara: $L_"nn" = "mean"("ReLU"(-hat(x))^2)$.],
      text(weight: "bold", fill: sage.darken(15%))[II.],
      [*Kryterium Bohma* $|u_a| \le c_s = sqrt((T_e + T_i)/m_a)$: prędkość jonów ograniczona prędkością dźwięku w plazmie.],
      text(weight: "bold", fill: amber.darken(15%))[III.],
      [*Zachowanie strumienia* $nabla dot (n_a u_a) approx 0$: brak źródeł/ujść cząstek wewnątrz domeny. Dywergencja aproksymowana różnicami centralnymi.],
    )
  ]

  #v(4pt)

  #card("8. Funkcja straty i procedura treningu", fill-color: navy)[
    #formula[$cal(L) = underbrace(L_"rec", "MSE") + beta underbrace(L_"KL", "spójność") + w_1 underbrace(L_"nn", "≥0") + w_2 underbrace(L_"Bohm", "Bohm") + w_3 underbrace(L_"div", "∇·j")$]

    #v(2.5pt)
    #grid(columns: (1fr, 1fr), gutter: 7pt,
      [
        #set text(size: 9.5pt)
        - Optymalizator: Adam, $"lr" = 2 times 10^(-4)$
        - Batch: 128, do 500 epok
        - Gradient clipping: 5.0
        - ReduceLROnPlateau + early stopping
        - Mixed precision (AMP) na GPU
      ],
      [
        #set text(size: 9.5pt)
        - KL annealing: $beta: 0 arrow 1$ przez 100 epok
        - $w_1 = 10^(-3)$ (nieujemność)
        - $w_2 = 5 times 10^(-4)$ (Bohm)
        - $w_3 = 3 times 10^(-3)$ (zachowanie strumienia)
        - GroupNorm zamiast BatchNorm (stabilność)
      ],
    )
    #v(2pt)
    #plain[KL annealing zapobiega kolapsowi posterioru — posterior stopniowo się uczy zamiast od razu kolapować do prioru.]
  ]

  #v(4pt)

  #card("9. Dekoder residualny", fill-color: teal)[
    Dekoder odwzorowuje $"concat"(z, c) in RR^{136}$ na 22 mapy 104×50:

    #formula[$RR^136 arrow.r "FC"(2048) arrow.r "reshape" 13 times 7 arrow.r 3 times ["ConvTranspose" + "ResBlock"] arrow.r "Conv" 22"ch" arrow.r 104 times 50$]

    #v(2pt)
    Każdy blok ConvTranspose (512→256→128→64) uzupełniony #text(weight: "bold")[blokiem residualnym]:

    #v(2pt)
    #resblock-viz()

    #v(2pt)
    #plain[Skip connections utrzymują gradient płynący podczas treningu — dekoder stabilnie rekonstruuje wszystkie 22 pola fizyczne bez zanikania gradientu.]
  ]
],
)

#v(5pt)

// ══════════════════════════════════════════════════════════
//  PASEK DOLNY — PODSUMOWANIE
// ══════════════════════════════════════════════════════════

#block(width: 100%, radius: 11pt, clip: true,
  fill: rgb("#364d68"), stroke: none,
  [
    #block(width: 100%, height: 3.5pt,
      fill: gradient.linear(teal, sage, amber, angle: 0deg))
    #pad(x: 16pt, top: 9pt, bottom: 10pt)[
      #grid(columns: (1fr, 1fr, 1fr, 1fr), gutter: 14pt,
        [
          #text(size: 10.5pt, weight: "bold", fill: teal)[Hybrydowy enkoder]
          #v(2pt)
          #text(size: 9.5pt, fill: rgb("#c8d8ea"))[CNN wychwytuje lokalne wzorce plazmy; Transformer modeluje globalne zależności zasięgu — razem kodują pełny stan SOL w 128 liczbach.]
        ],
        [
          #text(size: 10.5pt, weight: "bold", fill: sage)[Warunkowa generacja]
          #v(2pt)
          #text(size: 9.5pt, fill: rgb("#c8d8ea"))[Wystarczy 8 parametrów eksperymentu, by model natychmiast wygenerował 22 realistyczne mapy SOL — bez żadnej symulacji SOLPS-ITER.]
        ],
        [
          #text(size: 10.5pt, weight: "bold", fill: amber)[Prawa fizyki jako ograniczenia]
          #v(2pt)
          #text(size: 9.5pt, fill: rgb("#c8d8ea"))[Trzy kary (nieujemność, kryterium Bohma, zachowanie strumienia) gwarantują, że sieć #text(style: "italic", fill: white)[nigdy] nie wygeneruje niefizycznych wyników.]
        ],
        [
          #text(size: 10.5pt, weight: "bold", fill: white)[Kluczowy wynik]
          #v(2pt)
          #text(size: 9.5pt, fill: rgb("#c8d8ea"))[PI-CVAE generuje kompletny opis stanu SOL w #text(weight: "bold", fill: white)[~1 ms] zamiast godzin — umożliwiając kampanie optymalizacyjne dotychczas #text(weight: "bold", fill: white)[praktycznie niemożliwe do przeprowadzenia].]
        ],
      )
    ]
  ],
)
