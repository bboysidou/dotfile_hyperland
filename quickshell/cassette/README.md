# Cassette Deck

Lecteur QML/QtMultimedia pour Quickshell, inspiré des platines cassette.
Versions vérifiées : Quickshell 0.3.2, Qt/QtMultimedia 6.12.0,
backend FFmpeg, Hyprland 0.57.1 (configuration Lua existante).
Aucun paquet ajouté. Cava, déjà installé, sert aux aiguilles.
YouTube utilise mpv 0.41.0, yt-dlp 2026.10.26 et Deno déjà installés.

## Utilisation intégrée

Le shell principal importe `qs.cassette` et crée `DeckWindow { visible: false }`.
Afficher le lecteur depuis un terminal de la session :

```sh
qs ipc -p ~/.config/quickshell/shell.qml call cassette show
```

Autres méthodes IPC : `hide`, `play`, `pause`, `stop`, `next`, `previous`,
`status`, et `open file:///chemin/morceau.flac` (chargement sans lecture automatique).
Espace bascule lecture/pause ; Ctrl+O ouvre des fichiers ; Échap masque la fenêtre.
Masquer la fenêtre laisse la lecture continuer, mais suspend Cava et les aiguilles.
La fermeture par le gestionnaire de fenêtres masque aussi la fenêtre Quickshell.

Un raccourci global `quickshell:cassette` est enregistré. Pour lui attribuer
une touche, ajouter au fichier **actif** `~/.config/hypr/config/keymaps.lua`,
avec une combinaison libre de votre choix :

```lua
hl.bind("SUPER + ALT + C", hl.dsp.global("quickshell:cassette"))
```

Cette liaison clavier n'a pas été ajoutée automatiquement.
La règle `title = "^Cassette Deck$", float = true` a été ajoutée dans
`~/.config/hypr/modules/windowrules.lua`. Si nécessaire, exécuter
`hyprctl reload` puis `hyprctl configerrors` dans la session.

## YouTube : vidéos et playlists de chaînes

Cliquez sur **YouTube…**, collez le lien d’une vidéo ou d’une playlist publiée
par une chaîne, puis **Écouter**. Les liens `youtube.com/playlist?list=…` sont
acceptés. Un lien de vidéo avec `&list=…` ouvre la playlist entière ; pour écouter
seulement la vidéo, retirez le paramètre `list`.

Le lecteur récupère les titres avec yt-dlp, affiche les pistes et les enchaîne
avec mpv. Précédent/Suivant et un clic dans la liste changent de piste. Après
trois secondes, Précédent revient d’abord au début du morceau. Les vidéos
signalées privées/supprimées sont filtrées ; une piste qui échoue est sautée
si une suivante existe, avec un message dans l’interface. À la fin, la lecture
s’arrête. Une chaîne complète et ses différents onglets ne constituent pas une
playlist : utilisez le lien d’une playlist de son onglet « Playlists ».

### Mix YouTube et liens directs

Les liens `watch?v=…&list=RD…&index=…` sont des Mix YouTube. Le lecteur conserve
la vidéo de départ avec le Mix et commence sur cette vidéo lorsqu’elle est
présente dans la liste extraite. Les paramètres de suivi et `index` sont retirés,
mais le paramètre `v` est conservé. Les anciennes URL `playlist?list=RD…` sont
converties vers une URL avec vidéo de départ lorsque l’identifiant le permet.

Un Mix étant continuellement alimenté, son extraction est bornée à **50 pistes**
par ouverture pour éviter d’attendre indéfiniment. À la fin de cette liste,
rouvrez le lien pour obtenir un nouveau lot. Les playlists ordinaires ne sont
pas soumises à cette limite.

Collez directement le lien complet dans **YouTube…**, sans retirer `list`.
L’IPC `open` reconnaît maintenant aussi ces liens, comme la méthode `youtube` :

```sh
qs ipc -p ~/.config/quickshell/shell.qml call cassette open 'https://www.youtube.com/watch?v=3Ts_DKtzry8&list=RDgngiaY3XE_c&index=2'
```

Un lien sans paramètre `list` reste une vidéo seule, sans piste suivante.

Les boutons de transport, volume et progression pilotent mpv. Le déplacement
est désactivé si le flux ne le permet pas, notamment certains directs.
Votre fonction Bash `mpva` reste inchangée ; Quickshell lance directement mpv
avec votre sélection de formats `234/233/bestaudio/best`, sans scripts ni
configuration mpv utilisateur. Les fichiers locaux restent lus par QtMultimedia.
Ouvrir une nouvelle source arrête la précédente.

Commande IPC (remplacer le lien par un vrai lien) :

```sh
qs ipc -p ~/.config/quickshell/shell.qml call cassette youtube 'https://www.youtube.com/playlist?list=IDENTIFIANT'
```

Pour une instance autonome, utilisez le chemin `~/.config/quickshell/cassette`
avec `-p`. Aucun fichier audio permanent n’est téléchargé ; la liste et les
métadonnées sont mémorisées. Aucun cookie de navigateur n’est lu automatiquement.
Les contenus privés, soumis à connexion ou refusés par YouTube peuvent échouer.
En cas de problème, essayer le lien dans un terminal avec `mpva 'URL'` et vérifier
la version de yt-dlp.

## Historique et favoris

Dans **YouTube…**, choisissez **Historique** ou **Favoris ★**.
L’historique garde les dix derniers liens de vidéos ou playlists ouverts,
sans doublons ; une réécoute remet le lien en tête. Le titre est mis à jour
dès qu’il est disponible. Un lien valide peut être conservé même si son accès échoue.

Cliquez sur **☆** dans l’historique pour ajouter une entrée aux favoris.
Dans la fenêtre principale, **☆ Vidéo** enregistre la piste courante et
**☆ Playlist** enregistre toute la playlist. Une étoile pleine **★** permet de
retirer le favori. Les favoris sont indépendants de l’historique et ne sont
pas limités à dix. Cliquez sur un titre pour réécouter.

## État persistant

Les réglages sont enregistrés dans `$XDG_STATE_HOME/quickshell-cassette.ini`,
ou par défaut `~/.local/state/quickshell-cassette.ini` :

- `YouTubeHistory` : les dix derniers liens et leurs titres ;
- `YouTubeFavorites` : vidéos et playlists favorites ;
- `PlayerState` : volume, dernière source, liste de pistes, morceau et position ;
- `WindowState` : largeur et hauteur de fenêtre.

Au démarrage, le lecteur restaure la dernière source **en pause**.
Pour YouTube, le dernier contenu de playlist est restauré depuis la sauvegarde,
sans réseau ; appuyer sur Play ouvre le morceau courant. Pour actualiser une
playlist modifiée par sa chaîne, rouvrez son lien depuis les favoris/l’historique.
La position est réappliquée lorsque le flux autorise le déplacement. Pour les
fichiers locaux, les fichiers doivent toujours exister au même emplacement.

L’état est sauvegardé après les commandes, régulièrement pendant la lecture
(toutes les cinq secondes), et à la fermeture. Après une interruption brutale,
quelques secondes de progression peuvent être perdues. Stop remet la position
à zéro. La position de la fenêtre sur le bureau reste gérée par Hyprland.

Les données personnelles restent hors du dossier à partager. Deux instances
simultanées peuvent remplacer leurs derniers réglages respectifs : privilégiez
une seule instance intégrée ou autonome.

## Lancement autonome

```sh
qs -p ~/.config/quickshell/cassette
```

Éviter de lancer simultanément les versions autonome et intégrée : elles
utilisent le même nom de raccourci global. L'IPC autonome utilise
`qs ipc -p ~/.config/quickshell/cassette call cassette show`.

## Modules

- `DeckController.qml` : commandes communes, file de lecture et restauration.
- `DeckState.qml` : état de lecture et taille de fenêtre.
- `YoutubeUrls.js`, `YoutubePlaylist.qml` : validation des liens et extraction des playlists.
- `YoutubeLibrary.qml` : dialogue YouTube, historique et favoris.
- `YoutubeHistory.qml` : historique persistant de 10 liens, titres et déduplication.
- `YoutubeEngine.qml` : mpv audio et connexion JSON IPC, avec yt-dlp pour YouTube.
- `DeckEngine.qml` : MediaPlayer, AudioOutput, playlist, métadonnées,
  navigation et lecture d'un dossier avec FolderListModel.
- `DeckWindow.qml` : fenêtre native Quickshell, dialogues Qt, IPC et raccourci.
- `Cassette.qml`, `Reel.qml` : façade et bobines, animation suspendue en pause.
- `VuMeter.qml`, `MeterFeed.qml` : aiguilles et analyse Cava stéréo.
- `DeckButton.qml`, `DeckSlider.qml` : contrôles sombres indépendants du style Qt.

Les dossiers sont parcourus au premier niveau, triés par nom ; pas de scan récursif.
Ouvrir des fichiers/dossiers remplace la playlist et attend Play.
La fin d'un morceau passe au suivant ; la fin de playlist arrête la lecture.
Précédent revient au début après trois secondes, sinon au morceau précédent.
La liste locale, le morceau, le volume et la position sont restaurés en pause.
Ce lecteur ne publie pas de service MPRIS : le service `Players.qml` du dashboard
reste réservé aux lecteurs MPRIS existants.

## Source des vumètres

Cava analyse la sortie **système**, avec `pulse/auto`, comme le visualiseur
existant. D'autres applications peuvent donc influencer les aiguilles.
Deux bandes spectrales stéréo sont affichées : ce ne sont pas des mesures VU
RMS calibrées en dB, ni une analyse isolée du morceau. Aucun niveau aléatoire
n'est utilisé en fonctionnement normal. Si Cava échoue, les aiguilles reviennent
à zéro ; la lecture reste disponible.

## Vérification

```sh
~/.config/quickshell/cassette/tests/run.sh
```

Le script utilise les outils installés (`ffmpeg`, Python 3, Quickshell,
`/usr/lib/qt6/bin/qmllint`) et génère deux WAV de quatre secondes dans
`/tmp/cassette-test-audio`. Il vérifie dossier/URL accentuée, métadonnées,
durée, volume, lecture, pause, stop, seek, navigation, fin de playlist et
fichier absent. Une commande Cava simulée vérifie parsing stéréo et redémarrage.
`TestYoutube.qml` vérifie les URL, commandes et événements IPC simulés,
les métadonnées et le changement d’état entre deux vidéos.
`TestHistory.qml` vérifie la limite, l’ordre, les doublons, les titres et
la restauration dans un second processus ; les tests utilisent un dossier
d’état temporaire et ne touchent pas l’historique personnel.
Le test Mix couvre le lien `watch` complet, la vidéo de départ, la limite
d’extraction et les transitions. Un test avec **mpv réel**, une sortie audio
nulle et des fichiers WAV locaux enregistre les événements de remplacement
manuel et les fins de lecture ; ces événements sont ensuite rejoués dans le
moteur QML pour vérifier qu’un ancien arrêt ne bloque pas une nouvelle piste.
Ce test ne vérifie pas la connexion Unix de session ni le streaming YouTube.
Les tests de playlist lancent un substitut yt-dlp et vérifient les titres,
le filtrage, la navigation, l’enchaînement et les favoris. Des lancements séparés
vérifient la sauvegarde/restauration du volume, de la liste, des positions locales
et YouTube, ainsi que de la taille de fenêtre. Aucun test ne modifie votre état.
`TestVisual.qml` produit `/tmp/cassette-preview.png` ; `TestLibrary.qml` produit
`/tmp/cassette-library-preview.png`.

Le lint Qt 6 désactive uniquement les catégories import et unresolved-type,
car les métadonnées installées de Quickshell ne résolvent pas PostReloadHook /
GlobalShortcut dans qmllint. Le chargement réel dans Quickshell valide ces types.

Résultats dans l'environnement restreint : tests moteur, vumètres simulés,
rendu hors écran et syntaxe Lua réussis ; import `qs.cassette` vérifié séparément.
Sortie sonore, dialogues natifs, IPC de session, raccourci global et placement
Hyprland doivent encore être confirmés depuis le bureau : accès aux sockets
PipeWire/PulseAudio/Wayland/DBus refusé dans l'environnement d'exécution.

## Retirer l’intégration

Supprimer l’import `qs.cassette` et l’instance `DeckWindow` du shell,
puis la règle Hyprland dédiée et l’éventuel raccourci clavier.
Les sauvegardes initiales ont été supprimées à la demande du propriétaire.
