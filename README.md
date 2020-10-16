# Sudoku Scan

Dette har vært mitt sommerprosjekt 2020 og var et naturlig valg fordi det kombinerer digital bildebehandling og maskinlæring. 

Jeg begynte med en Python-prototype i Jupyter Notebook for å lage en proof of concept, og for å utforske OpenCV her.

Deretter prøvde jeg å overføre denne kunnskapen over til Flutter, slik at appen kunne publiseres både hos iOS og Android med samme kodebase. Dessverre støtte jeg på problemer når det kom til bildegjennkjenning.

Derfor byttet jeg ut Flutter med Swift. Med dette kunne jeg benytte de verktøyene jeg hadde bruk for, på bekostning av å kun kunne publisere til iOS.

På grunn av skiftet fra Flutter til Swift ble prosjektet mer omfattende og er dermed noe jeg fremdeles utvikler på siden av studiene.

## Mål

Jeg har laget en skisse i Adobe XD for å lettere visualisere hvordan det endelige resultatet er ment å se ut.
Her er en enkel GIF til demonstasjon:

<p align="center">
  <img src="https://media.giphy.com/media/UaQniQXzUsVV47d9qq/giphy.gif">
</p>

Foreløpig er selve sudokubrettet i skissen tilnærmet en blåkopi av appen fra Sudoku.com, bortsett fra små endringer i ikonene og plasseringer. Dette er gjort for å raskere få på plass noe som ser riktig ut, uten å bruke for mye tid på å finne opp kruttet på nytt. 


## Prototyping
Jeg prototyper som nevnt i Python i Jupyter Notebook. Her leker jeg meg masse med spennende funksjoner i OpenCV. I bildet under kan man se resulatet etter bildebehandlingen for å hente ut brettet.

Det originale bildet:

