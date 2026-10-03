"""Add readable instructions/licenses outside the signed .app; record ZIP checksum."""
from pathlib import Path
import hashlib, zipfile
root=Path(__file__).resolve().parents[1]
archive=root/'downloads/ENERGY-INC-macOS.zip'
instructions='''ENERGY INC. 0.2.0 — MAC

1. Ziehe ENERGY INC.app in deinen Programme-Ordner und öffne die App.
2. Godot, Xcode oder Steam sind zum Spielen nicht erforderlich.
3. Falls macOS den Start blockiert: Nach dem Startversuch unter
   Systemeinstellungen > Datenschutz & Sicherheit > Dennoch öffnen
   die einzelne App freigeben, sofern du diesem Download vertraust.
   Die App ist ad-hoc signiert, aber nicht von Apple notarisiert.

Steuerung: WASD bewegen, Maus umsehen, Leertaste springen.
E greifen/laden/liefern, F Maschine starten, Q ablegen (halten zum Werfen).
Esc: Pause, Neustart, Vollbild, Beenden.

Wasser + Koffein + Mango mischen (5 Sekunden), Charge zum Füller tragen,
sechs leere Dosen am Spender holen und einsetzen. Füller starten.
Sechs fertige Dosen zum Liefertisch tragen: $420, danach neuer Auftrag.
Frist 180 Sekunden; Verspätung kostet $100. Pause hält die Zeit an.

Universal-App für Intel und Apple Silicon, empfohlen ab macOS 11.
Ein echter macOS-Start und physische Controller müssen noch getestet werden.
Dieser Entwicklungsstand ist Einzelspieler; Koop folgt in einer späteren Phase.

Projekt und Anleitung:
https://github.com/redboxergaming-hash/ENENERGYway/tree/work
'''
notices=(root/'THIRD_PARTY_NOTICES.md').read_text()+'\n\n'+(root/'licenses/GODOT.txt').read_text()+'\n\n'+(root/'art/fonts/LICENSE.txt').read_text()
with zipfile.ZipFile(archive,'a',zipfile.ZIP_DEFLATED) as z:
    for name,content in [('START-HERE-MAC.txt',instructions),('THIRD-PARTY-NOTICES.txt',notices)]:
        data=content.encode()
        if name in z.namelist():
            assert z.read(name)==data,'Re-export before repackaging changed instructions.'
        else:
            z.writestr(name,data)
(root/'downloads/ENERGY-INC-macOS.zip.sha256').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  ENERGY-INC-macOS.zip\n')
print(f'Packaged {archive.stat().st_size:,} bytes including instructions and licenses.')
